use image_compare::Algorithm;
use rustler::types::atom;
use rustler::{Encoder, Env, NifResult, Term};

rustler::atoms! {
    decode_error,
    different,
    dimension_mismatch,
    images_match,
    not_found,
    write_failure
}

#[rustler::nif]
pub fn diff<'a>(env: Env<'a>, before_path: &str, after_path: &str, output_path: &str) -> NifResult<Term<'a>> {
    let before = match image::open(before_path) {
        Ok(image) => image.to_rgb8(),
        Err(_) => return Ok((atom::error(), not_found()).encode(env)),
    };

    let after = match image::open(after_path) {
        Ok(image) => image.to_rgb8(),
        Err(_) => return Ok((atom::error(), not_found()).encode(env)),
    };

    match image_compare::rgb_similarity_structure(&Algorithm::RootMeanSquared, &before, &after) {
        Ok(result) => {
            if result.score == 1.0 {
                return Ok((atom::ok(), images_match()).encode(env));
            } else {
                let output_file = format!("{}.png", output_path);
                
                match result.image.to_color_map().save(&output_file) {
                    Ok(_) => return Ok((atom::error(), different(), output_file).encode(env)),
                    Err(_) => return Ok((atom::error(), write_failure()).encode(env)),
                }
            }
        }
        Err(_) => return Ok((atom::error(), dimension_mismatch()).encode(env)),
    }
}

rustler::init!("Elixir.SnappyImageDiff", [diff]);

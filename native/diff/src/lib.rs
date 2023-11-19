use image::io::Reader as ImageReader;
use image::{DynamicImage, GenericImage, GenericImageView, Rgba};
use rustler::types::atom;
use rustler::{Encoder, Env, NifResult, Term};
use std::io::Cursor;

rustler::atoms! {
    different,
    decode_error,
    dimension_mismatch,
    not_found,
    write_failure
}

#[rustler::nif]
pub fn diff_and_save<'a>(
    env: Env<'a>,
    before_path: &str,
    after_path: &str,
    output_path: &str,
) -> NifResult<Term<'a>> {
    let before = match open_image(before_path) {
        Ok(image) => image,
        Err((atom, message)) => return Ok((atom, message).encode(env)),
    };

    let after = match open_image(after_path) {
        Ok(image) => image,
        Err((atom, message)) => return Ok((atom, message).encode(env)),
    };

    let (after_width, after_height) = after.dimensions();

    let (before_width, before_height) = before.dimensions();

    if (after_width != before_width) || (after_height != before_height) {
        return Ok((atom::error(), dimension_mismatch()).encode(env));
    }
    let result = build_diff(&before, &after);

    if result != before {
        match result.save(output_path) {
            Ok(_) => return Ok((different()).encode(env)),
            Err(_) => return Ok((atom::error(), write_failure()).encode(env)),
        }
    } else {
        return Ok((atom::ok()).encode(env));
    }
}

#[rustler::nif]
pub fn diff<'a>(env: Env<'a>, before_path: &str, after_path: &str) -> NifResult<Term<'a>> {
    let before = match open_image(before_path) {
        Ok(image) => image,
        Err((atom, message)) => return Ok((atom, message).encode(env)),
    };

    let after = match open_image(after_path) {
        Ok(image) => image,
        Err((atom, message)) => return Ok((atom, message).encode(env)),
    };

    let (after_width, after_height) = after.dimensions();

    let (before_width, before_height) = before.dimensions();

    if (after_width != before_width) || (after_height != before_height) {
        return Ok((atom::error(), dimension_mismatch()).encode(env));
    }

    let result = build_diff(&before, &after);

    if result != before {
        let mut bytes: Vec<u8> = Vec::new();
        match result.write_to(&mut Cursor::new(&mut bytes), image::ImageOutputFormat::Png) {
            Ok(_) => return Ok((different(), bytes).encode(env)),
            Err(_) => return Ok((atom::error(), write_failure()).encode(env)),
        }
    } else {
        return Ok((atom::ok()).encode(env));
    }
}

fn open_image(path: &str) -> Result<DynamicImage, (atom::Atom, atom::Atom)> {
    match ImageReader::open(path) {
        Ok(reader) => match reader.decode() {
            Ok(image) => Ok(image),
            Err(_) => Err((atom::error(), decode_error())),
        },
        Err(_) => Err((atom::error(), not_found())),
    }
}

fn build_diff(before: &DynamicImage, after: &DynamicImage) -> DynamicImage {
    let (width, height) = before.dimensions();

    let mut result = DynamicImage::new_rgba8(width, height);

    for y in 0..height {
        for x in 0..width {
            let new_color: [u8; 4];
            let pixel: Rgba<u8>;

            let before_pixel: Rgba<u8> = before.get_pixel(x, y);
            let after_pixel: Rgba<u8> = after.get_pixel(x, y);

            let alpha = before_pixel[3];

            let is_diff = before_pixel[0] != after_pixel[0]
                || before_pixel[1] != after_pixel[1]
                || before_pixel[2] != after_pixel[2];

            let mut new_red = after_pixel[0];
            let mut new_green = after_pixel[1];
            let mut new_blue = after_pixel[2];

            if is_diff {
                new_red = 255;
                new_green = 0;
                new_blue = 0;
            }

            new_color = [new_red, new_green, new_blue, alpha];
            pixel = Rgba(new_color);
            result.put_pixel(x, y, pixel);
        }
    }

    result
}

rustler::init!("Elixir.SnappyImageDiff", [diff]);

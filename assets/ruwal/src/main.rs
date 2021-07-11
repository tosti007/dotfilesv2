use anyhow::{/*anyhow,*/ bail, Result};
use glob::glob;
use is_executable::IsExecutable;
use std::{fs, path::PathBuf, process::Command};
use tera::{Context, Tera};

mod helpers;

fn cache_dir() -> PathBuf {
    let mut d = dirs::cache_dir().unwrap();
    d.push("ruwal");
    d
}
fn cache_item(f: &str) -> PathBuf {
    let mut d = cache_dir();
    d.push(f);
    d
}
fn config_item(f: &str) -> PathBuf {
    let mut d = dirs::config_dir().unwrap();
    d.push("ruwal");
    d.push(f);
    d
}

fn read_theme() -> Result<toml::Value> {
    let theme = config_item("theme.toml");
    if !theme.is_file() {
        bail!("Theme file does not exists.");
    }
    let theme = fs::read_to_string(&theme)?;
    let theme = toml::from_str(&theme)?;
    Ok(theme)
}
fn write_theme(theme: &toml::Value) -> Result<()> {
    use std::io::Write;
    let mut file = fs::File::create(cache_item("theme.toml"))?;
    let data = toml::to_string(theme)?;
    file.write_all(data.as_bytes())?;
    Ok(())
}

fn main() -> Result<()> {
    println!("Readig theme file");
    let mut engine = config_item("templates");
    engine.push("**");
    engine.push("*");
    let mut engine = Tera::new(engine.to_str().unwrap())?;
    engine.autoescape_on(vec![]);
    helpers::register(&mut engine);

    let theme = read_theme()?;
    fs::create_dir_all(cache_dir())?;
    write_theme(&theme)?;
    let theme = Context::from_serialize(theme)?;

    println!("Parsing templates");
    for template in engine.get_template_names() {
        let output = cache_item(template);
        fs::create_dir_all(output.parent().unwrap())?;
        let output = fs::File::create(output)?;
        engine.render_to(template, &theme, output)?;
    }

    println!("Executing hooks");
    for item in glob(
        config_item(
            "hooks/**/
*",
        )
        .to_str()
        .unwrap(),
    )
    .unwrap()
    .filter_map(|f| f.ok())
    .filter(|f| f.is_executable())
    {
        let status = Command::new(&item)
            .current_dir(item.parent().unwrap())
            .status();
        match status {
            Ok(i) => {
                if !i.success() {
                    println!("{} exected with {}", item.display(), i);
                }
            }
            Err(e) => println!("{} failed: {}", item.display(), e),
        }
    }
    Ok(())
}

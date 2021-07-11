use color_processing::{Color, ParseError as ColorError};
use std::{collections::HashMap, convert::TryFrom, str::FromStr};
use strum_macros::EnumString;
use tera::{Error as TeraError, Filter, Tera, Value};
use thiserror::Error;

trait HasName {
    fn name() -> &'static str;
}

trait RegisterFilter: Filter {
    fn register(engine: &mut Tera);
}

impl<T: 'static + Filter + HasName + Default> RegisterFilter for T {
    fn register(engine: &mut Tera)
    {
        engine.register_filter(T::name(), T::default());
    }
}

pub fn register(engine: &mut Tera) {
    FilterColor::register(engine);
}

#[derive(Error, Debug)]
enum FilterColorError {
    #[error("Value \"{0}\" is not a string")]
    NotAString(String),
    #[error("Value \"{0}\" is not a boolean")]
    NotABool(String),
    #[error("Value \"{0}\" is not a correct color")]
    NotAColor(String, ColorError),
    #[error("Value \"{0}\" is not a correct format")]
    NotAFormat(String, strum::ParseError),
}

impl From<FilterColorError> for TeraError {
    fn from(e: FilterColorError) -> Self {
        use FilterColorError as F;
        let msg = e.to_string();
        match e {
            F::NotAString(_) => TeraError::msg(msg),
            F::NotABool(_) => TeraError::msg(msg),
            F::NotAColor(_, n) => TeraError::chain(msg, n),
            F::NotAFormat(_, n) => TeraError::chain(msg, n),
        }
    }
}

#[derive(Debug, EnumString)]
#[strum(ascii_case_insensitive)]
enum FilterColorFormat {
    Hex,
    Aarrggbb,
    Rrggbb,
    Rrggbbaa,
}

impl TryFrom<&Value> for FilterColorFormat {
    type Error = FilterColorError;

    fn try_from(value: &Value) -> Result<Self, Self::Error> {
        value
            .as_str()
            .map(|v| {
                Self::from_str(v).map_err(|e| {
                    FilterColorError::NotAFormat(value.as_str().unwrap().to_string(), e)
                })
            })
            .ok_or_else(|| FilterColorError::NotAString(value.to_string()))?
    }
}

fn color_from_value(value: &Value) -> Result<Color, FilterColorError> {
    let value = match value {
        Value::String(s) => Ok(s),
        _ => Err(FilterColorError::NotAString(value.to_string())),
    }?;
    Color::new_string(value).map_err(|e| FilterColorError::NotAColor(value.to_string(), e))
}

#[derive(Default)]
struct FilterColor;

impl HasName for FilterColor {
    fn name() -> &'static str {
        "color"
    }
}

impl Filter for FilterColor {
    fn filter(&self, v: &Value, args: &HashMap<String, Value>) -> Result<Value, TeraError> {
        use FilterColorFormat as F;
        let v = color_from_value(v)?;

        let format = args.get("format").map(F::try_from).unwrap_or(Ok(F::Hex))?;

        Ok(Value::String(match format {
            F::Hex => {
                let s = format!("#{:02X}{:02X}{:02X}", v.red, v.green, v.blue);
                if v.alpha == u8::MAX {
                    s
                } else {
                    format!("{}{:02X}", s, v.alpha)
                }
            }
            F::Aarrggbb => format!("{:02X}{:02X}{:02X}{:02X}", v.alpha, v.red, v.green, v.blue),
            F::Rrggbb => format!("{:02X}{:02X}{:02X}", v.red, v.green, v.blue),
            F::Rrggbbaa => format!("{:02X}{:02X}{:02X}{:02X}", v.red, v.green, v.blue, v.alpha),
        }))
    }

    fn is_safe(&self) -> bool {
        true
    }
}

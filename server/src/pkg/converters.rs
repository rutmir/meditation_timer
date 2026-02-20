use std::{collections::{HashMap, HashSet}, str::FromStr};

pub fn build_millis_keys(keys: HashSet<String>) -> (Vec<i64>, HashMap<i64, String>) {
    let millis_to_key = keys.iter().fold(
        HashMap::<i64, String>::new(),
        |mut hm, x| -> HashMap<i64, String> {
            let key = x.clone();
            let parts = key.split("_");
            if let Some(str_millis) = parts.last() { 
                let some_milis: Option<i64> = FromStr::from_str(str_millis).ok();
                if let Some(millis) = some_milis {
                    hm.insert(millis, x.clone());
                }    
            }

            hm
        } 
    );

    let mut millis = millis_to_key.keys().cloned().collect::<Vec<i64>>();
    millis.sort();

    (millis, millis_to_key)
}


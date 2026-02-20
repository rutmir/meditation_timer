use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Copy, Clone, Hash, Eq, PartialEq)]
pub enum Statistic {
    #[serde(rename = "view")]
    View,
    #[serde(rename = "get")]
    Get,
}

// impl Statistic {
//     pub fn iterator() -> impl Iterator<Item = Statistic> {
//         [Statistic::View, Statistic::Get].iter().copied()
//     }
// }
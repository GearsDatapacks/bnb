pub type Allegiance {
  Royalist
  Rogue
  FreeBeast
  WildBeast
}

pub const allegiances = [Royalist, Rogue, FreeBeast, WildBeast]

pub fn to_string(allegiance: Allegiance) -> String {
  case allegiance {
    Royalist -> "Royalists"
    Rogue -> "Rogues"
    FreeBeast -> "Freebeasts"
    WildBeast -> "Wildbeasts"
  }
}

pub fn from_string(string: String) -> Result(Allegiance, Nil) {
  case string {
    "Royalists" -> Ok(Royalist)
    "Rogues" -> Ok(Rogue)
    "Freebeasts" -> Ok(FreeBeast)
    "Wildbeasts" -> Ok(WildBeast)
    _ -> Error(Nil)
  }
}

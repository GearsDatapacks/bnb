pub type Lazy(a) {
  Lazy(initialiser: fn() -> a)
}

@external(javascript, "../bnb_ffi.mjs", "initLazy")
pub fn get(lazy: Lazy(a)) -> a

pub type LazyDict(key, value) {
  LazyDict(list: List(#(key, value)))
}

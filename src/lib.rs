#[cfg(test)]
mod tests;
mod argparse;
mod partitioner;
pub struct Config {
    encrypt: bool,
    home_src: Option<String>,
    root: Option<i32>,
    swap: Option<i32>,
    home: Option<i32>,
    hostname: Option<String>,
    username: Option<String>,
    mountpoint: Option<String>,
}
impl Config {
    fn parse_disk_size(size: String) -> i32 {
        let _ = size;
        4
    }
}
pub fn install() {
    let conf: Config = argparse::parse();
    if conf.encrypt {
        // do sth
    }
}

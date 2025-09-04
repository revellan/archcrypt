use super::*;
#[test]
fn disk_size() {
    assert_eq!(Config::parse_disk_size(String::from("4GB")), 4);
}
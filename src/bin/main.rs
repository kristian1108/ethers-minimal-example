use test::bindings;

fn main() {
    let mut c = bindings::i_reader::ChainStorage {
        pool: Default::default(),
        assets: vec![],
        dexes: vec![],
        liquidity_lock_period: 0,
        market_order_timeout: 0,
        max_limit_order_timeout: 0,
        lp_deduct: Default::default(),
        stable_deduct: Default::default(),
        is_position_order_paused: false,
        is_liquidity_order_paused: false,
    };

    c.liquidity_lock_period = 1;

    println!("Hello");
}
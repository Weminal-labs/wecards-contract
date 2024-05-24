
/// Module: suicards
module suicards::gamecards {
    use std::vector;
    use std::string::{String, utf8};
    use sui::package;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext, sender};
    use sui::event;
    use sui::transfer::{Self, transfer, public_transfer};
    use sui::display;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::balance::{Self, Balance};
    use sui::pay::{Self};

    // import the gameboard module
    use suicards::gameboard::{Self, GameBoard as GB};


    const DEFAULT_FEE: u64 = 200_000_000;


    public struct Suicards has key, store{ 
        id: UID,
        game: u64, 
        player: address,
        score: u64,
        // game ket qua 
        true_score: u64,
        failed: u64, 
        game_over: bool,
    }

    public struct GameRoom has key {
        id: UID,
        main_address: address,
        game_count: u64,
        fee: u64,
        balance: Balance<GAMECARDS>,
    }


    // public struct PlayerVaults has key {

    // }
    
    // public struct adminGame has key{
    //     id: UID,
    //     Admin_address: address,
    //     game_count: u64,
    //     fee: u64, 
    //     balance: Balance<SUI> 
    // }


    public struct GAMECARDS has drop {}
    
    fun init(otw: GAMECARDS, ctx: &mut TxContext) {
        //create currency 
        let (treasury, metadata) = coin::create_currency(
            otw,
            8,                // decimals
            b"SHELLS",           // symbol
            b"Shell game card",       // name
            b"Token for gaming", // description
            option::none(),   // icon url
            ctx
        );

        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury, tx_context::sender(ctx));


        let room = create_game(ctx);

        transfer::share_object(room);

        // todo object game 

    }

    public fun mint(
        treasury_cap: &mut TreasuryCap<GAMECARDS>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
    ) {

    let coin = coin::mint(treasury_cap, amount, ctx);
    transfer::public_transfer(coin, recipient)
    }   

    public fun create_game( ctx: &mut TxContext): GameRoom{
        GameRoom { 
            id: object::new(ctx),
            main_address: sender(ctx),
            game_count: 0,
            fee: DEFAULT_FEE,
            balance: balance::zero<GAMECARDS>() 
        }
    }


    //create room
    public entry fun create_room(game_object: &mut GameRoom, fee: vector<Coin<GAMECARDS>>, ctx: &mut TxContext){

        // pay fee to create rooom 
        let (paid, remainder) = merge_and_split<GAMECARDS>(fee, game_object.fee, ctx); // paid de thanh toan

        coin::put(&mut game_object.balance, paid);
        // refund to user address
        transfer::public_transfer(remainder, tx_context::sender(ctx));

    
    }



    fun merge_and_split<GAMECARDS>(
        coins: vector<Coin<GAMECARDS>>, amount: u64, ctx: &mut TxContext
    ): (Coin<GAMECARDS>, Coin<GAMECARDS>) {
        
        let base = vector::pop_back(&mut coins); 
        pay::join_vec(&mut base, coins);
        let coin_value = coin::value(&base);
        assert!(coin_value >= amount, coin_value);
        (coin::split(&mut base, amount, ctx), base)
    }

}

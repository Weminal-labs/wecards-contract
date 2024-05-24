
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


    public struct Gamescorecards has key, store{ 
        id: UID,
        player: address,
        score: u64, // diem hien tai
        true_score: u64, // so lan dung
        failed: u64,  // so lan fail
        game_over: bool,
    }

    public struct GameRoom has key {
        id: UID,
        main_address: address,
        game_count: u64,
        fee: u64,
        balance: Balance<GAMECARDS>,
    }


    // EVENT STRUCT
   public struct NewCardEvent has copy, drop {
        game_id: ID,
        player: address,
        score: u64
    }



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


    }
    
    // coin management
    public fun mint(
        treasury_cap: &mut TreasuryCap<GAMECARDS>, 
        amount: u64, 
        recipient: address, 
        ctx: &mut TxContext,
    ) {

    let coin = coin::mint(treasury_cap, amount, ctx);
    transfer::public_transfer(coin, recipient)
    }   


    //TODO: set up account game ( 5)



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
    public entry fun create_room(game_object: &mut GameRoom,mut fee: vector<Coin<GAMECARDS>>, ctx: &mut TxContext){
        // pay fee to create rooom 

        // convert address to vector 
        let (paid, remainder) = merge_and_split<GAMECARDS>(fee, game_object.fee, ctx); // paid de thanh toan

        coin::put(&mut game_object.balance, paid);
        // refund to user address
        transfer::public_transfer(remainder, tx_context::sender(ctx));


        // Create game board 
        let player = tx_context::sender(ctx); // playder la nguoi goi contract 
        let uid = object::new(ctx); // uid: 0x/.12304 
        let random_number = object::uid_to_bytes(&uid);
        let game_board = gameboard::Init_game(random_number);
        
        let score = *gameboard::get_score(&game_board);

        let cards = Gamescorecards {
            id: uid,
            player: player,
            score: score,
            true_score: 0,
            failed: 0,
            game_over: false,
        };


        event::emit(NewCardEvent{
            game_id: object::uid_to_inner(&cards.id),
            player: player,
            score: score,
        });
        
        game_object.game_count = game_object.game_count + 1;

        transfer::public_transfer(cards, player);
    }



    fun merge_and_split<GAMECARDS>(
        mut coins: vector<Coin<GAMECARDS>>, amount: u64, ctx: &mut TxContext
    ): (Coin<GAMECARDS>, Coin<GAMECARDS>) {
        
        let mut base = vector::pop_back(&mut coins); 

        pay::join_vec(&mut base, coins);
        let coin_value = coin::value(&base);
        assert!(coin_value >= amount, coin_value);
        (coin::split(&mut base, amount, ctx), base)
    }

}

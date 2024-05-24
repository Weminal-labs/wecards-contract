module suicards::gameboard {


    use std::string::{utf8, String};
   
    #[test_only] use sui::test_scenario::{Self, ctx};
    #[test_only] use std::debug;
    
   public  struct GameMove has store {
        direction: u64,
        player: address,
    }
    #[test_only] const CREATOR: address = @0x0000000000000000000000000000000000000000000000000000000000000000;
    // #[test_only] const USER: address = @0x82b93f4a24a9488b7f6d76494ea7e80bf251e8827f28b173336ea2da0768effe;


    public struct TopGame has key{
        id: UID,
        name: String,
    }

    public  struct GameBoard has store, drop, copy {
        score: u64, 
        last_phase: u64,
        Bonus_points: u64,
        game_over: bool,
    }

    // ENTRY FUNCTIONS
    public fun Init_game(random_number: vector<u8>): GameBoard{
        
        let game_board = GameBoard {
            score: 0,
            last_phase:  0,
            Bonus_points: 0,
            game_over: false
        };

        game_board
    }


    public fun get_score(points: &GameBoard): &u64{
        &points.score
    }




    #[test]
    #[expected_failure]
    fun test_transfer(){
    
    
    let scenario = test_scenario::begin(CREATOR);
    

    let var = caculate();
    //   mint(ctx(&mut scenario));
    //   test_scenario::next_tx(&mut scenario, CREATOR);
    //   let nft = test_scenario::take_from_address<Shop>(&scenario, CREATOR);
      
    //   // Expected fail because sender is not owner of object
    //   test_scenario::next_tx(&mut scenario, @0x0123);
    //   transferObject(nft, ctx(&mut scenario));
    debug::print(&var);
    test_scenario::end(scenario);
  }





}
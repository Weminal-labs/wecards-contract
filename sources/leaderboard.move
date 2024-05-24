module suicards::leaderboard {

    use std::vector;
    use sui::object::{Self, ID, UID};
    use sui::tx_context::{Self, TxContext};



    // Leaderboard struct
    public struct SuicardsLeaderboard has key{
        id: UID,
        max_leader_count: u64, // max number of players in the leaderboard
        Topplayer: vector<Topplayer>,   // vector of top players
        min_score: u64, // minimum score to be in the leaderboard
    }
        
    // Topplayer struct
    public struct Topplayer has key, store {
        id: UID,
        player: address,
        score: u64,
    }


    // init leaderboard
    // fun init(ctx: &mut TxContext){
    //     create_leaderboard(ctx);
    // }

    // ENTRY FUNCTIONS
    public entry fun create_leaderboard(ctx: &mut TxContext){
        let leaderboard = SuicardsLeaderboard{
            id: object::new(ctx),
            max_leader_count: 20,
            Topplayer: vector<Topplayer>[],
            min_score: 0,
        };

        // share the leaderboard object
        transfer::share_object(leaderboard);
    }

}
global function VoteSkipInit

array<string> playerSkipVoteNames = [] // list of players who have voted, is used to see how many have voted 
bool skipEnabled = true

void function VoteSkipInit(){
    // add commands here. i added some varieants for accidents, however not for brain damage. do whatever :P
    AddClientCommandCallback("!skip", CommandSkip) //!skip force will change the map if your name is in adminNames
    AddClientCommandCallback("!SKIP", CommandSkip)
    AddClientCommandCallback("!Skip", CommandSkip)

    AddClientCommandCallback("!rtv", CommandSkip) // rock the vote. requested by @Hedelma
    AddClientCommandCallback("!RTV", CommandSkip)

    // ConVar
    skipEnabled = GetConVarBool( "pv_skip_enabled" )
}

/*
 *  COMMAND LOGIC
 */

bool function CommandSkip(entity player, array<string> args){
    if(!IsLobby()){
        printl("USER TRIED VOTING")
        
        if(args.len() == 1 && args[0] == "force"){
            // check for admin names
            if(adminNames.find(player.GetPlayerName()) != -1){
                for(int i = 0; i < GetPlayerArray().len(); i++){
                    SendHudMessageBuilder(GetPlayerArray()[i], ADMIN_SKIPPED, 255, 200, 200)
			    }
                CheckIfEnoughSkipVotes(true)
                return true
            }
            SendHudMessageBuilder(player, MISSING_PRIVILEGES, 255, 200, 200)
            return false
        }

        // check if skipping is enabled
        if(!skipEnabled){
            SendHudMessageBuilder(player, COMMAND_DISABLED, 255, 200, 200)
            return false
        }

        // check if player has already voted //TODO fix this up
        if(!PlayerHasVoted(player, playerSkipVoteNames)){
            // add player to list of players who have voted 
            playerSkipVoteNames.append(player.GetPlayerName())

            // send message to everyone
            for(int i = 0; i < GetPlayerArray().len(); i++){
                if(playerSkipVoteNames.len() > 1) // semantics
                    SendHudMessageBuilder(GetPlayerArray()[i], playerSkipVoteNames.len() + MULTIPLE_SKIP_VOTES, 255, 200, 200)
                else
                    SendHudMessageBuilder(GetPlayerArray()[i], playerSkipVoteNames.len() + ONE_SKIP_VOTE, 255, 200, 200)
			}
        } 
        else {
            // Doesnt let the player vote twice, name is saved so even on reconnect they cannot vote twice
            // Future update might check if the player is actually online but right now i am too tired
            SendHudMessageBuilder(player, ALREADY_VOTED, 255, 200, 200)
        }
    }
    CheckIfEnoughSkipVotes()
    return true
}

/*
 *  HELPER FUNCTIONS
 */

void function CheckIfEnoughSkipVotes(bool force = false){
    // check if enough have voted
    // change "half" in the if statement to whatever var or amount you want
    int half = ceil(1.0 * GetPlayerArray().len() / 2).tointeger()
    int quarter = ceil(1.0 * GetPlayerArray().len() / 4).tointeger() //fixed spelling, fuck you coopyy

    if(playerSkipVoteNames.len() >= half || force){ // CHANGE half
        SetServerVar("gameEndTime", 1.0) // end this game 
        playerSkipVoteNames.clear()
    }
}
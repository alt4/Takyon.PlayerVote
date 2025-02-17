global function VoteExtendInit

array<string> playerExtendVoteNames = [] // list of players who have voted, is used to see how many have voted 
bool extendMapMultipleTimes = false // false: map can only be extended once; true: map can be extended indefinetly
bool hasMapBeenExtended = false // makes sure map can only be extended once
float extendMatchTime = 3.5 // how much time should be added after successful !extend vote in minutes

void function VoteExtendInit(){
    #if SERVER
    // add commands here. i added some varieants for accidents, however not for brain damage. do whatever :P
    AddClientCommandCallback("!extend", CommandExtend)
    AddClientCommandCallback("!EXTEND", CommandExtend)
    AddClientCommandCallback("!Extend", CommandExtend)
    #endif
}

/*
 *  COMMAND LOGIC
 */

bool function CommandExtend(entity player, array<string> args){
    if(!IsLobby()){
        printl("USER TRIED EXTENDING")
        
        // admin force vote
        if(args.len() == 1 && args[0] == "force"){
            // check for admin names
            if(adminNames.find(player.GetPlayerName()) != -1){
                for(int i = 0; i < GetPlayerArray().len(); i++){
                    SendHudMessageBuilder(GetPlayerArray()[i], "Admin extended map time", 255, 200, 200)
                    CheckIfEnoughExtendVotes(true)
			    }
                return true
            }
            SendHudMessageBuilder(player, "Missing Privileges!", 255, 200, 200)
            return true
        }

        // check if already extended and settings
        if(hasMapBeenExtended && !extendMapMultipleTimes ){
            SendHudMessageBuilder(player, "The map cannot be extended twice", 255, 200, 200)
            return false
        }

        // check if player has already voted
        if(!PlayerHasVoted(player, playerExtendVoteNames)){ 
            // add player to list of players who have voted 
            playerExtendVoteNames.append(player.GetPlayerName())

            // send message to everyone
            for(int i = 0; i < GetPlayerArray().len(); i++){
                if(playerExtendVoteNames.len() > 1) // semantics
                    SendHudMessageBuilder(GetPlayerArray()[i], playerExtendVoteNames.len() + " Players Want To Play This Map Longer\nExtend this map by typing !extend in the console", 255, 200, 200)
                else
                    SendHudMessageBuilder(GetPlayerArray()[i], playerExtendVoteNames.len() + " Player Wants To Play This Map Longer\nExtend this map by typing !extend in the console", 255, 200, 200)
			}
        } 
        else {
            // Doesnt let the player vote twice, name is saved so even on reconnect they cannot vote twice
            // Future update might check if the player is actually online but right now i am too tired
            SendHudMessageBuilder(player, "You have already voted!", 255, 200, 200)
        }
    }
    CheckIfEnoughExtendVotes()
    return true
}

/*
 *  HELPER FUNCTIONS
 */

void function CheckIfEnoughExtendVotes(bool force = false){
    // check if enough have voted
    // change "half" in the if statement to whatever var or amount you want
    int half = ceil(1.0 * GetPlayerArray().len() / 2).tointeger()
    int quarter = ceil(1.0 * GetPlayerArray().len() / 4).tointeger() //fixed spelling, fuck you coopyy

    if(playerExtendVoteNames.len() >= half || force){ // CHANGE half
        SetServerVar( "gameEndTime", expect float(GetServerVar("gameEndTime")) + (60 * extendMatchTime))
        // message everyone
        for(int i = 0; i < GetPlayerArray().len(); i++){
            SendHudMessageBuilder(GetPlayerArray()[i], "Map has been extended!", 255, 200, 200)
        }
        hasMapBeenExtended = true
        playerExtendVoteNames.clear()
    }
}
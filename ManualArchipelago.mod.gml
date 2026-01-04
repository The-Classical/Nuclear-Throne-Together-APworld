/// Mod attached to the manual NT archipelago
// Used to make several of it's features work

/*
// NT-MANUAL SPECIFIC GUIDE;

1: Already done, if you have this file on your PC.

2: Go to nuclear throne on steam, right click > Properties > Betas, click the beta participation dropdown and select "ntt_development".

3: go to either "[...]\steamapps\common\Nuclear Throne\mods" or [...]\AppData\Local\nuclearthrone\mods" and put this file there. create the folder if it doesn't exist.
Use '/Loadmod ManualArchipelago' to load the mod.

4: Launch Nuclear throne.
4b: Press "PLAY" to enter character select.

5:
Enter '/healthitems X', where X is the number of "+2 Max Health" items you have.
Enter '/ammoitems X', where X is the number of "+25% Max Ammo" items you have.
Enter '/levelitems X', where X is the number of "Max Level +1" items you have.
Enter '/raditems X', where X is the number of "+20 Starting Rads" items you have.
Enter '/harditems X', where X is the number of "Starting Difficulty +1" traps you have.

Enter '/mutitems X', where X is the name of every mutation item you've recieved, E.I "rabbit paw bloodlust long arms eagle eyes open mind". order doesn't matter.
(I recommend you save this to a text file.)

Enter '/canloop 1' if you have "Loop Access".
Enter '/canvault 1' if you have "Vault Access".

Character restrictions are the honor system.
Don't start with crowns, unless you have vault access* [FOR NOW.]

6:
Play the game!
/*

#define init
global.HealthItems	= 0;
global.AmmoItems	= 0;
global.LevelItems	= 0;
global.ArsenalItems	= 0
global.RadItems		= 0;
global.HardItems    = 0;
global.MaxWeapon	= 1;
global.CanLoop		= false;
global.CanVault		= false;
global.seedmod		= 0;
global.sprMutNone	= sprite_add("sprNoMut.png", 1, 12, 16)
for(var i = 1; i <= 28; i += 1) {
	skill_set_active(i, false)
}

#macro progression_color    	15702447
#macro useful_color		15240045
#macro filler_color		15658496
#macro trap_color		7504122

#define chat_command(cmd, par, plr)
    switch(cmd){
        case "healthitems":
            global.HealthItems = real(par);
            trace_color("# of health items set to " + string(global.HealthItems) + ".", useful_color)
            
            return true;
        break
        
        case "ammoitems":
            global.AmmoItems = real(par);
            trace_color("# of ammo items set to " + string(global.AmmoItems) + ".", useful_color)
            
            return true;
        break
        
        case "levelitems":
            global.LevelItems = real(par);
            trace_color("# of level items set to " + string(global.LevelItems) + ".", progression_color)
            
            return true;
        break
        
        case "weaponitems":
            global.MaxWeapon = (real(par)*2) + 1;
            trace_color("# of weapoon items set to " + string(real(par)) + ".", progression_color)
            
            return true;
        break
        
        case "raditems":
            global.RadItems = real(par);
            trace_color("# of rad items set to " + string(global.RadItems) + ".", filler_color)
            
            return true;
        break

	case "harditems":
            global.HardItems = real(par);
            trace_color("# of difficulty traps set to " + string(global.HardItems) + ".", trap_color)
            
            return true;
        break
        
        case "canloop":
            global.CanLoop = real(par) > 0;
            if (global.CanLoop){
                trace_color("Looping is now possible. Happy looping!", progression_color);
            } else {
                trace_color("Looping is no longer possible.", progression_color);
            }
            
            return true;
        break
        
        case "canvault":
            global.CanVault = real(par) > 0;
            if (global.CanVault){
                trace_color("Crown vaults are open!", progression_color);
            } else {
                trace_color("Crown vaults are now closed.", progression_color);
            }
            
            return true;
        break
        
        case "mutitems":
            var _string = string_upper(par)
			for(var i = 1; i <= 28; i += 1) {
				skill_set_active(i, false)
				if string_pos(skill_get_name(i), _string){
					skill_set_active(i, true)
					trace("enabled " + skill_get_name(i) + ".");
				}
			}
			
            trace_color("Available mutations set.", progression_color);
            return true;
        break
    }

#define game_start
	GameCont.hard += global.HardItems;
    with (Player){
        var _hpmult = (global.HealthItems * 0.25) + 0.5
        var _ammomult = (global.AmmoItems * 0.25) + 0.5
        
        maxhealth = floor(maxhealth * _hpmult) // health Multiplier
        my_health = min(my_health, maxhealth)
        
        for(var i = 1; i <= 5; i++) { // ammo multipliers
			typ_amax[i] = floor(typ_amax[i] * _ammomult)
			ammo[i] = floor(ammo[i] * _ammomult)
        }
			    
    }
    GameCont.rad = (global.RadItems * 20)
    
#define step
    if (GameCont.level > (global.LevelItems + 1)) && global.LevelItems != 8 { // Level cap
        GameCont.rad = min(GameCont.rad, 60 * (global.LevelItems + 2));
    }
    if !global.CanLoop with (Generator){
        maxhealth = 4000;
        my_health = maxhealth;
        spr_idle = sprBigGeneratorInactive
    }
    if !global.CanVault with (ProtoStatue){
        if !instance_exists(SpiralCont){
        	instance_destroy()
        }
    }
    if !skill_get_active(mut_last_wish) || skill_get(mut_last_wish) with (SkillIcon){
        if (skill == mut_last_wish) {
        	skill = 0
        	sprite_index = global.sprMutNone
        	name = "@sNONE"
        	text = "@dNO MUTATIONS#AVAILABLE :("
        }
    }
    /*with instances_matching(WepPickup, "ArchipelagoCheck", undefined){
    	if weapon_get_area(wep) > (global.MaxWeapon){
    		wep = weapon_decide(0, 4, false, null)
    		global.seedmod++
    	}
    	ArchipelagoCheck = 1
    }*/
    
#define weapon_decide(min_hard, max_hard, _gold, _exclude)
/*
Choose a random weapon from the weapon drop pool, respecting drop conditions
*/
if (UberCont.hardmode){
    max_hard = ceil((max_hard - 16) / 3 + 2);
}

max_hard += player_count_race(char_robot);
min_hard += 5 * ultra_get(char_robot, 1);
max_hard = max(0, max_hard);
min_hard = min(min_hard, max_hard);

var _chosen = wep_screwdriver;

if ("wep" in self && wep != wep_none){
    _chosen = wep;
}

else if (_gold > 0){
    _chosen = choose(wep_golden_wrench, wep_golden_machinegun, wep_golden_shotgun, wep_golden_crossbow, wep_golden_grenade_launcher, wep_golden_laser_pistol);
    
    if (GameCont.loops > 0 && choose(true, false)){
        _chosen = choose(wep_golden_plasma_gun, wep_golden_slugger, wep_golden_splinter_gun, wep_golden_screwdriver, wep_golden_bazooka, wep_golden_assault_rifle);
    }
}

var _list = ds_list_create();
var weapon_count = weapon_get_list(_list, min_hard, max_hard);

ds_list_shuffle(_list);

for (var i = 0; weapon_count > i; i ++){
    var _wep = _list[| i];
    var _valid = !((_wep == _exclude || (is_array(_exclude) && array_find_index(_exclude, _wep) >= 0)) || ((_gold > 0 && !weapon_get_gold(_wep)) || (_gold < 0 && weapon_get_gold(_wep))));
    
    if (_valid){
        switch(_wep){
            case wep_super_disc_gun: _valid = ("curse" in self && curse > 0); break;
            case wep_golden_nuke_launcher:
            case wep_golden_disc_gun: _valid = (UberCont.hardmode); break;
            case wep_gun_gun: _valid = (crown_current == crwn_guns); break;
        }
        
        if (_valid){
            _chosen = _wep;
            break;
        }
    }
}

ds_list_destroy(_list);
return _chosen;
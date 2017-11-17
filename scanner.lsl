

key ownerKey;
integer ownerLightBus;
integer listenOLB;
integer listenInput;

list unitList;
list keyList;
integer unitCount;

string thinking = "think";
string fix = "Mac Startup Sound";
string error = "error";
string startup = "Mac Startup Sound";
//string startup = "Windows XP Startup";
string shutdown = "Windows XP Shutdown";

key unitKey;  
string unitName = "none";
vector unitColor;
float unitRate;
float unitFan;
float unitTemp;
string unitPersona = "n/a";
integer unitLightBus;
integer listenULB;

string input = "";

integer getChannel(key UUID) {
    return -1-(integer)("0x" + llGetSubString(UUID, -7, -1))+106;
}

init() {
    llPlaySound(startup, 0.3);
    updateText("INIT");
    llParticleSystem([]);
    ownerKey = llGetOwner();
    ownerLightBus = getChannel(ownerKey);
    listenOLB = llListen(ownerLightBus+1, "", NULL_KEY, "");
    listenInput = llListen(ownerLightBus+2, "", NULL_KEY, "");
    llListenControl(listenOLB, FALSE);
    llListenControl(listenInput, FALSE);
    updateText("Ready!");
}

updateText(string message) {
    //llMessageLinked(LINK_ALL_OTHERS, 122, message, (string)unitColor);
    llMessageLinked(LINK_ALL_OTHERS, 122, (string)unitColor, message);
}

//internal scaner 0 00000000-0000-0000-0000-000000000000 say this is a test
customLightBusCommand() {
    input = "clbc";
    llListenControl(listenInput, TRUE);
    llTextBox(ownerKey," Pleas enter LightBus command\n",ownerLightBus+2);
}

scan(float range) {
    llSensor("", NULL_KEY, AGENT, range, PI);
}

key getUUID(string name) {
    unitName = name;
    integer x = llListFindList(unitList, [name]);
    return llList2String(keyList, x);
}

permission(key UUID) {
    llOwnerSay("Asking " + unitName + " for permission.");
    unitLightBus = -1-(integer)("0x" + llGetSubString((string)UUID, -7, -1))+106;
    llListen(unitLightBus, "", NULL_KEY, "");
    //llSay(unitLightBus, "auth scanner " + (string)ownerKey);
    llOwnerSay("Connecting cable...");
    getPort(NULL_KEY);
}

auth(key UUID) {
    llOwnerSay("Asking " + unitName + " for authenfication.");
    llListen(unitLightBus, "", NULL_KEY, "");
    llSay(unitLightBus, "auth scanner " + (string)ownerKey);
    //llOwnerSay("Connecting cable...");
    //getPort(NULL_KEY);
}

getPort(key UUID) {
    llSay(unitLightBus, "color-q");
    llSay(unitLightBus, "persona-q");
    if (UUID == NULL_KEY) { 
        llOwnerSay("sending [port-connect data-1]");
        llSay(unitLightBus, "port-connect data-1"); }
    else {
        //llOwnerSay("sending [port-connect " + (string)UUID + "]"); 
        //llSay(unitLightBus, "port-connect " + (string)UUID);
        }
}

connect(key UUID) {
    updateText("Unit: " + unitName);
    particles(UUID);
    mainMenu(ownerKey);
}

disconnect() {
    busSpam = FALSE;
    llParticleSystem([]);
    llListenControl(listenULB, FALSE);
    llOwnerSay("Disconnecting scanner.");
    llSay(unitLightBus, "port-disconnect data-1");
    llSay(unitLightBus, "remove scanner");
    unitName = "none";
    unitColor = <0,0,0>;
    unitPersona = "n/a";
    unitLightBus = -25432122;
    mainMenu(ownerKey);
}

particles(key UUID) {
    llParticleSystem([
        PSYS_PART_FLAGS, 0
            | PSYS_PART_FOLLOW_VELOCITY_MASK
            | PSYS_PART_INTERP_COLOR_MASK
            | PSYS_PART_TARGET_POS_MASK
            | PSYS_PART_RIBBON_MASK,
        PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
        PSYS_PART_START_COLOR, unitColor,
        PSYS_PART_END_COLOR, unitColor,
        PSYS_PART_START_ALPHA, 1.0,
        PSYS_PART_END_ALPHA, 1.0,
        PSYS_PART_START_SCALE, <0.04, 0.04, 0>,
        PSYS_SRC_TEXTURE, TEXTURE_BLANK,
        PSYS_SRC_TARGET_KEY, UUID,
        PSYS_SRC_MAX_AGE, 0.0,
        PSYS_PART_MAX_AGE, 10.0,
        PSYS_SRC_BURST_RATE, 0.0,
        PSYS_SRC_BURST_PART_COUNT, 1
    ]);
}

beep() { updateText("beep"); llWhisper(PUBLIC_CHANNEL, "beep"); }

mainMenu(key UUID) {
    llListenControl(listenOLB, TRUE);
    llSetTimerEvent(60);
    string x = "Spam: off";
    if (busSpam) { x = "Spam: on"; }
    //llDialog(UUID, "Select an option.\nCurrent unit: " + unitName + "\n" + x, ["SCAN","SPAM","DISPLAY","DISCONNECT","TEST","CLEAR","RESET","BREAK","FIX","STARTUP","SHUTDOWN"], ownerLightBus+1);
    //llDialog(UUID, "Select an option.\nCurrent unit: " + unitName + "\n" + x, ["TEST","BREAK","FIX","STARTUP","SHUTDOWN"], ownerLightBus+1);  //RP
    llDialog(UUID, "Select an option.\nCurrent unit: " + unitName + "\n" + x, ["RP","SPAM","next","DISPLAY","CLEAR","RESET","SCAN","DISCONNECT","AUTH"], ownerLightBus+1);
}

rpMenu(key UUID) {
    llListenControl(listenOLB, TRUE);
    llSetTimerEvent(60);
    llDialog(UUID, "Select an RP action.\nCurrent unit: " + unitName + "\n", ["TEST","BREAK","FIX","STARTUP","SHUTDOWN"], ownerLightBus+1);  //RP
}

selectMenu(key UUID) {
    llListenControl(listenOLB, TRUE);
    llSetTimerEvent(60);
    string text = "[" + (string)unitCount + "] units detected.";
    updateText(text);
    llDialog(UUID, text, unitList, ownerLightBus+1);
}

disableListen() {
    llListenControl(listenOLB, FALSE);
    llListenControl(listenInput, FALSE);
    llSetTimerEvent(0);
}

integer busSpam = FALSE;
toggleSpam() {
    if (!busSpam) { busSpam = TRUE; updateText("Spam enabled..."); llLoopSound(thinking, 0.1); }
    else { busSpam = FALSE; llStopSound(); updateText("Spam disabled."); }
}

processCommand(string input) {
    string command = llGetSubString(input, 0, llSubStringIndex(input, " ")-1);
    string params = llGetSubString(input, llSubStringIndex(input, " ")+1, -1);
    //hoverText("Heard command: " + command);
    //hoverText("Heard params: " + params);
    if (command == "color") { messageColor(params); }
    if (command == "power") { messagePower(params); }
    if (command == "persona") { messagePersona(params); }
    //if (command == "persona-eject") { messagePersona(""); }
    //if (command == "poke") { messagePoke(params); }
    //if (command == "peek") { messagePeek(params); }
    //if (command == "bolts") { messageBolts(params); }
    //if (command == "charge") { messageCharge(params); }
    //if (command == "weather") { messageWeather(params); }
}

messageColor(string input) {
    list rgb = llParseString2List(input, [" "], []);
    unitColor = <llList2Float(rgb, 0), llList2Float(rgb, 1), llList2Float(rgb, 2)>;
}

messagePersona(string input) {
    if (input == "") {
        updateText("Updating persona...");
    } else {
        unitPersona = input;
        updateText("Persona: " + input);
    }
}

string power;
messagePower(string input) {
    float powerFloat = (float)input * 100;
    integer powerInt = (integer)powerFloat;
    power = (string)powerInt;
    //hoverText("Current power: " + (string)powerInt + "%");
}

messagePoke(string input) {
    updateText("Poke: " + input);
}

messagePeek(string input) {
    updateText("Peek: " + input);
}

messageBolts(string input) {
    if (input == "off") {
        updateText("Unit unlocked");
    } else {
        updateText("Unit locked");
    }
}

messageCharge(string input) {
    if (input == "start") {
        updateText("Charge: started");
    } else {
        updateText("Charge: ended");
    }
}

messageWeather(string input) {
    string weather = llGetSubString(input, 0, llSubStringIndex(input, " ")-1);
    integer temp = (integer)llGetSubString(input, llSubStringIndex(input, " ")+1, -1);
    updateText("Weather: " + weather + "\nTemp: " + (string)temp + "C");
}

clearScreen() {
    updateText("INIT");
    mainMenu(ownerKey);
}

displayVitals() {
    updateText(unitName + " : " + unitPersona);
    updateText("unit make and model");
    updateText("unlocked permissions?");
    updateText("power voltage status");
    updateText("power settings");
    updateText("integrity etc temp");
    updateText("vox filters");
    updateText("network, motors, ftl, audio, mind, video");
    mainMenu(ownerKey);
}

default
{
    state_entry() { init(); }
    
    listen(integer c, string n, key k, string m) {
        if (c == ownerLightBus+1) {
            disableListen();
            if (m == "SCAN") { llPlaySound(thinking, 0.3); updateText("Scanning for units..."); scan(20);  }
            else if (m == "DISCONNECT") { updateText("Disconnecting..."); disconnect(); mainMenu(ownerKey); }
            else if (m == "AUTH") { 
                llOwnerSay("Still under Developing....."); 
                key UUID = getUUID(m);
                auth(UUID);
                mainMenu(ownerKey); 
            } else if (m == "TEST") { beep(); }
            else if (m == "CLEAR") { clearScreen(); }
            else if (m == "RESET") { llResetScript(); }
            else if (m == "OK") { mainMenu(ownerKey); }
            else if (m == "SPAM") { toggleSpam(); mainMenu(ownerKey); }
            else if (m == "DISPLAY") { displayVitals(); mainMenu(ownerKey); }
            else if (m == "BREAK") { llPlaySound(error, 0.3); updateText("!!! ERROR !!!"); mainMenu(ownerKey); }
            else if (m == "FIX") { llPlaySound(fix, 0.3); updateText("!!! ERROR RESOLVED !!!"); mainMenu(ownerKey); }
            else if (m == "STARTUP") { llPlaySound(startup, 0.3); mainMenu(ownerKey); }
            else if (m == "SHUTDOWN") { llPlaySound(shutdown, 0.3); mainMenu(ownerKey); }
            else if (m == "RP") { rpMenu(ownerKey); }
            else if (m == "next") { /*customLightBusCommand();*/ llOwnerSay("Still under Developing....."); mainMenu(ownerKey); }
            else {
                key UUID = getUUID(m);
                permission(UUID);
            }
        } else if (c == ownerLightBus+2) {  // Textbox Input
            disableListen();
            if (input == "clbc") {   //####################################################
                input = "";
                llOwnerSay("Still under Developing....."); 
                string command = m;
                key UUID = getUUID(m);
                if (m == "") { command = "internal scanner 0 "+(string)UUID+" say this is a test"; }
                llOwnerSay("Execute: \""+command+"\" on unit's LightBus"/*+" (dont execute anything, still under development)"*/); 
                llSay(unitLightBus, command);
                mainMenu(ownerKey); 
            } else { 
            input = "";
            }
        } else if (c == unitLightBus) {
            if (busSpam == TRUE) { llOwnerSay(unitName + " LB: " + m); updateText(m); }
            if (m == "accept " + (string)ownerKey) { llOwnerSay("Connection approved."); llSay(unitLightBus, "add scanner"); getPort(NULL_KEY); }
            else if (m == "add-confirm") { llOwnerSay("Device added.");  }
            else if (m == "add-fail") { llOwnerSay("Connection failed."); }
            else if (m == "remove-confirm") { updateText("Disconnected."); llOwnerSay("Disconnect successful."); }
            else if (m == "remove-fail") { updateText("Disconnect failed..."); llOwnerSay("Unable to remove."); }
            else if (llGetSubString(m, 0, 8) == "port-real") {
                key portUUID = (key)llGetSubString(m, 17, -1);
                connect(portUUID);
            }
            else if (llGetSubString(m, 0, 3) == "port") {
                key UUID = (key)llGetSubString(m, -36, -1);
                llOwnerSay("Port forward to: " + (string)UUID);
                getPort(UUID);
            } else { 
                processCommand(m); 
            }
        }
    }
    
    sensor(integer d)
    {
        unitList = [];
        keyList = [];
        integer x = 0;
        unitCount = d;
        while (x < d) {
            
            llOwnerSay("Found: " + llDetectedName(x));
            string llDialogConformUnitName = llGetSubString(llDetectedName(x), 0, 20);
            llOwnerSay("Convert it to: " + llDialogConformUnitName);
            unitList += llDialogConformUnitName;
            //unitList += llDetectedName(x);
            keyList += llDetectedKey(x);
            x++;
        }
        selectMenu(ownerKey);
    }
    
    no_sensor()
    {
        selectMenu(ownerKey);
    }
    
    touch_end(integer d) {
        mainMenu(ownerKey);
    }
    
    timer() {
        disableListen();
    }
}

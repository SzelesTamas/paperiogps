const WebSocketServer = require('ws');
const mysql = require('mysql');
const res = require('express/lib/response');
const { send } = require('express/lib/response');
const game_lib = require("boundary_fill.js")

arena = new game_lib.Arena("Szigetszentmiklos",
    new game_lib.MapPoint(47.372974, 18.996256),
    new game_lib.MapPoint(47.306302, 19.072626),
    100,
)
arena2 = new game_lib.Arena("Kerekegyhaza",
    new game_lib.MapPoint(46.9492, 19.4562),
    new game_lib.MapPoint(46.9273, 19.4965),
    10,
)

console.log("V12");

//arena = arena2;

const wss = new WebSocketServer.Server({
    port: 8080
});

const con = mysql.createConnection({
    host: "localhost",
    port: 3306,
    user: "mapconquest",
    password: "",
    database: "mapconquest"
});

const clients = new Map();
var serverViewUser = undefined;

function isUsernameTaken(username) {
    return new Promise((resolve => {
        var sql = `SELECT * FROM userdata WHERE userdata.username='${username}';`;
        con.query(sql, function (err, result) {
            if (err) throw err;
            if (result.length > 0) {
                resolve(true);
            }
            else {
                resolve(false);
            }
        });
    }))
}

function isValidUsernamePassword(username, password) {
    return new Promise((resolve => {
        var sql = `SELECT * FROM userdata WHERE username='${username}' AND password='${password}';`;
        con.query(sql, function (err, result) {
            if (err) throw err;
            if (result.length > 0) {
                resolve({ returnValue: true, userID: result[0].userID });
            }
            else {
                resolve({ returnValue: false, userID: undefined });
            }
        });
    }))
}

function addCoordsOfUser(userID, latitude, longitude, time) {
    var sql = `INSERT INTO usercoordinates (userID, latitude, longitude, timeSinceEpoch) VALUES (${userID}, ${latitude}, ${longitude}, ${time});`;
    con.query(sql, function (err) {
        if (err) throw err;
    });
    arena.updatePosition(userID, new game_lib.MapPoint(latitude, longitude));
    if (serverViewUser != undefined) {
        var toSend = {
            type: "addCoordsOfUser",
            latitude: latitude,
            longitude: longitude,
            userID: userID,
            time: time
        }
        serverViewUser.send(JSON.stringify(toSend));
    }
}

async function insertNewUser(username, password, email) {
    return new Promise((async resolve => {
        debugPrint("Trying to insert new user");
        if (await checkUserSignup(username, password, email)) {
            debugPrint("Inserting new user");
            var sql = `INSERT INTO userdata (username, password, email) VALUES ('${username}', '${password}', '${email}');`
            con.query(sql, function (err) {
                if (err) throw err;
            });
            resolve(true);
        }
        else {
            resolve(false);
        }
    }));
}

async function checkUserSignup(username, password, email) {
    return new Promise((async resolve => {
        var sql = `SELECT * FROM userdata WHERE username='${username}' OR email='${email}';`;
        con.query(sql, function (err, result) {
            if (err) throw err;
            if (result.length > 0) {
                resolve(false);
            }
            else {
                resolve(true);
            }
        });
    }))

}

function debugPrint(msg) {
    printToServerView(msg);
    console.log(msg);
}

function printToServerView(msg) {
    if (serverViewUser != undefined) {
        toSend = {
            type: "printToServerView",
            message: msg
        };
        serverViewUser.send(JSON.stringify(toSend));
    }
}

async function getUserIDFromUsername(username) {
    return new Promise((async resolve => {
        var sql = `SELECT userID FROM userdata WHERE username='${username}';`;
        con.query(sql, function (err, result) {
            if (err) throw err;
            if (result.length == 0) throw new Error("No matching username");
            resolve(result[0].userID);
        });
    }));
}

function deleteUserLocationData(userID) {

    return new Promise((resolve => {
        if (userID == undefined) resolve();
        else {
            if (serverViewUser != undefined) {
                var toSend = {
                    type: "deleteUserLocationData",
                    userID: userID
                };
                serverViewUser.send(JSON.stringify(toSend));
            }
            var sql = `DELETE FROM usercoordinates WHERE userID=${userID};`;
            con.query(sql, function (err) {
                if (err) throw err;
                resolve();
            })
        }
    }))
}

function sendAllLocationDataToServerView() {
    if (serverViewUser != undefined) {

        var sql = `SELECT timeSinceEpoch, latitude, longitude, userID FROM usercoordinates ORDER BY timeSinceEpoch;`
        con.query(sql, function (err, result) {
            if (err) throw err;
            result.userID = result.userID;
            var toSend = {
                type: "allLocationDataToServerView",
                data: result
            }
            serverViewUser.send(JSON.stringify(toSend));
        });
    }
}

wss.getUniqueID = function () {
    function s4() {
        return Math.floor((1 + Math.random()) * 0x10000).toString(16).substring(1);
    }
    return s4() + s4() + '-' + s4();
};

wss.on("connection", async function (ws) {
    debugPrint("new client connected");
    var clientData = {
        id: wss.getUniqueID(),
        userID: undefined,
    };
    clients.set(ws, clientData);

    ws.on("message", async function (data) {
        var msg = JSON.parse(data.toString());
        debugPrint("Message received:")
        debugPrint(msg);
        if (msg.type === "isUsernameTaken") {
            var toSend = { type: "isUsernameTakenReturn", returnValue: await isUsernameTaken(msg.username) };
            ws.send(JSON.stringify(toSend));
        }
        else if (msg.type === "isValidUsernamePassword") {
            var ret = await isValidUsernamePassword(msg.username, msg.password)
            var toSend = {
                type: "isValidUsernamePasswordReturn",
                returnValue: ret.returnValue,
                username: msg.username,
                password: msg.password,
                userID: ret.userID
            };
            ws.send(JSON.stringify(toSend));
        }
        else if (msg.type === "coordsOfUser") {
            addCoordsOfUser(msg.userID, msg.latitude, msg.longitude, msg.timeSinceEpoch);
        }
        else if (msg.type == "insertNewUser") {
            insertNewUser(msg.username, msg.password, msg.email);
        }
        else if (msg.type == "checkUserSignup") {
            var ret = await insertNewUser(msg.username, msg.password, msg.email);
            var toSend = {
                type: "checkUserSignupReturn",
                returnValue: ret,
            }
            if (ret.returnValue) {
                debugPrint(`User ${msg.username} signed up`);
            }
            ws.send(JSON.stringify(toSend));
        }
        else if (msg.type == "checkUserSignin") {
            var ret = await isValidUsernamePassword(msg.username, msg.password)
            var toSend = {
                type: "checkUserSigninReturn",
                returnValue: ret.returnValue,
                username: msg.username,
                userID: ret.userID
            };
            if (ret.returnValue) {
                debugPrint(`User ${ret.userID} logged in`);
            }
            ws.send(JSON.stringify(toSend));
        }
        else if (msg.type == "userLocationData") {
            debugPrint(msg);
            addCoordsOfUser(await getUserIDFromUsername(msg.username), msg.latitude, msg.longitude, msg.timeSinceEpoch);
        }
        else if (msg.type == "fillUserData") {
            clients.get(ws).userID = await getUserIDFromUsername(msg.username);
            arena.addPlayer(msg.username, clients.get(ws).userID, ws, 'red');
        }
        else if (msg.type == "requestFieldUpdate") {
            console.log("requested FieldUpdate");
            arena.sendDataToPlayers();
        }
    });

    ws.on("close", async () => {
        if (ws == serverViewUser) {
            serverViewUser = undefined;
        }
        // delete all location data
        await arena.removePlayer(clients.get(ws).userID);
        await deleteUserLocationData(clients.get(ws).userID);
        clients.delete(ws);
        debugPrint("Client has disconnected");
    })

    ws.onerror = function () {
        debugPrint("Some Error occurred");
    }

})


con.connect(function (err) {
    if (err) throw err;
    debugPrint("Connected to MySQL database");
})


debugPrint("The WebSocket server is running on port 8080");

setTimeout(arena.sendDataToPlayers, 100);
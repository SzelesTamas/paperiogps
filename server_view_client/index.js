var socket = new WebSocket('wss://api.mapconquest.tech');
var messageP = document.getElementById("Message");
var map;
const userLines = new Map();
const userPoints = new Map();
const userColor = new Map();
var drawnFields = new L.LayerGroup();

socket.onmessage = async function (event) {
    var msg = JSON.parse(event.data);
    if (msg.type == "printToServerView") {
        console.log(msg.message);
    }
    else if (msg.type == "deleteUserLocationData") {
        removeUser(msg.userID);
    }
    else if (msg.type == "addCoordsOfUser") {

        msg.userID = parseInt(msg.userID);
        if (!(userPoints.has(msg.userID))) {
            await addUser(msg.userID, msg.latitude, msg.longitude);
            refreshLines(msg.userID);
        }
        else {
            userPoints.get(msg.userID).push([msg.latitude, msg.longitude]);
            refreshLines(msg.userID);
        }

    }
    else if (msg.type == "allLocationDataToServerView") {

        msg.userID = parseInt(msg.userID);
        msg.data.forEach(async el => {
            if (!userPoints.has(el.userID)) {
                await addUser(el.userID, el.latitude, el.longitude);
            }
            else {
                userPoints.get(el.userID).push([el.latitude, el.longitude]);
            }
        });

        for (let [key, value] of userPoints) {
            refreshLines(key);
        }

    }
    else if (msg.type == "arenaData") {
        console.log(msg);
        newGrid = JSON.parse(msg.arenaData);
        refreshArenaGrid(newGrid, msg.upperLeftCornerLatitude, msg.upperLeftCornerLongitude, msg.gridUnitSize);
    }
}

function refreshArenaGrid(newGrid, upperLeftCornerLatitude, upperLeftCornerLongitude, gridUnitSize) {
    // delete all drawings
    drawnFields.clearLayers()
    for (var i = 0; i < newGrid.length; i++) {
        for (var j = 0; j < newGrid[i].length; j++) {
            bounds = [
                [upperLeftCornerLatitude - i * gridUnitSize, upperLeftCornerLongitude + j * gridUnitSize],
                [upperLeftCornerLatitude - (i + 1) * gridUnitSize, upperLeftCornerLongitude + (j + 1) * gridUnitSize]
            ];

            changeOwnerOfField(bounds, (newGrid[i][j].owner == "none" ? 'blue' : 'red'));
        }
    }
}

function changeOwnerOfField(bounds, ownerColor) {
    drawnFields.addLayer(L.rectangle(bounds, { color: ownerColor, stroke: false, fillOpacity: 0.7 }));
}


function generateRandomColor() {
    return new Promise(resolve => {
        var letters = '0123456789abcdef'.split('');
        var color = '#';
        for (var i = 0; i < 6; i++) {
            color += letters[Math.round(Math.random() * 15)];
        }
        resolve(color);
    })
}

function requestServerView() {
    sendUserData();
}

function requestFieldUpdate() {
    socket.send(JSON.stringify({ type: "requestFieldUpdate" }));
}

function initMap() {
    map = L.map('map').setView([47.342946, 19.032862], 13);

    var tiles = L.tileLayer('https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, ' +
            'Imagery © <a href="https://www.mapbox.com/">Mapbox</a>',
        id: 'mapbox/streets-v11',
        tileSize: 512,
        zoomOffset: -1
    }).addTo(map);

    drawnFields.addTo(map);
}

async function addUser(userID, latitude, longitude) {
    return new Promise(async resolve => {
        userPoints.set(userID, [[latitude, longitude]]);
        userLines.set(userID, undefined);
        var newColor = await generateRandomColor();
        userColor.set(userID, newColor);
        resolve();
    });
}

async function getLastPoint(userID) {
    return new Promise(async (resolve) => {
        var userP = await userPoints.get(userID);
        resolve(userP[userP.length - 1]);
    });
}

async function removeLines(userID) {
    return new Promise(async resolve => {
        var line = await userLines.get(userID);
        if (line != undefined) {
            await line.remove(map);
            resolve();
        }
        else {
            resolve();
        }
    });
}

async function refreshLines(userID) {
    await removeLines(userID);
    var points = await userPoints.get(userID);
    var col = await userColor.get(userID);
    var line = await L.polyline(points, { color: col });
    userLines.set(userID, line);
    line.addTo(map);
}

async function removeUser(userID) {
    await removeLines(userID);
    userPoints.delete(userID);
    userColor.delete(userID);
    userLines.delete(userID);
}

function sendUserData() {
    var toSend = {
        type: "fillUserData",
        username: "admin"
    };
    socket.send(JSON.stringify(toSend));
}






initMap();

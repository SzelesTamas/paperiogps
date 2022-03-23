var socket = new WebSocket('wss://api.mapconquest.tech');
var usernameInputField = document.getElementById("usernameInputField");
var passwordInputField = document.getElementById("passwordInputField");
var outputField = document.getElementById("demo");
var userID = -1;
var username = "__noname__";
var password = "__nopassword__";

socket.onmessage = function (event) {
    var msg = JSON.parse(event.data);

}

function error(err) {
    console.warn("ERROR(" + err.code + "): " + err.message);
}

const options = {
    enableHighAccuracy: true,
    timeout: 5000,
    maximumAge: 0
}

socket.onopen = async function (pos) {
    username = await localStorage.getItem("username");
    userID = await localStorage.getItem("userID");
    outputField.textContent = username + " " + userID;
    socket.send(JSON.stringify({
        type: "fillUserData",
        username: username
    }));
    navigator.geolocation.watchPosition(function (pos) {
        var toSend = {
            type: "coordsOfUser",
            userID: userID,
            latitude: pos.coords.latitude,
            longitude: pos.coords.longitude,
            timeSinceEpoch: (new Date().getTime()),
        };
        console.log(toSend);
        socket.send(JSON.stringify(toSend));
    }, error, options);
}




var socket = new WebSocket("ws://localhost:8080");
var usernameInputField = document.getElementById("usernameInputField");
var passwordInputField = document.getElementById("passwordInputField");
var errorMessage = document.getElementById("errorMessage");
var usernameTaken = false;
var testFinished = false;

// emittel is lehetne a kuldest asszem csinalni
socket.onmessage = async function (event) {
    var msg = JSON.parse(event.data);
    if (msg.type === "isUsernameTakenReturn") {
        usernameTaken = msg.returnValue;
        testFinished = true;
    }
    else if (msg.type === "isValidUsernamePasswordReturn") {
        if (msg.returnValue) {
            await localStorage.setItem("username", msg.username);
            await localStorage.setItem("userID", msg.userID);
            window.location.replace("game.html");
        }
    }
}

function delay(n) {
    return new Promise(function (resolve) {
        setTimeout(resolve, n);
    });
}

async function isValidRegisterData() {
    var confirmPasswordInputField = document.getElementById("confirmPasswordInputField");
    var emailInputField = document.getElementById("emailInputField");
    await isUsernameTaken();
    testFinished = false;
    await delay(100);
    if (!testFinished) {
        throw new Error("Too much server delay");
    }
    testFinished = false;
    if (confirmPasswordInputField.value != passwordInputField.value) {
        errorMessage.textContent = "Given passwords don't match";
    }
    else if (passwordInputField.value.length == 0) {
        errorMessage.textContent = "Too short password";
    }
    else if (passwordInputField.length > 20) {
        errorMessage.textContent = "Too long password";
    }
    else if (usernameTaken) {
        errorMessage.textContent = "This username is taken";
    }
    else if (usernameInputField.value.length > 20) {
        errorMessage.textContent = "Too long username";
    }
    else if (usernameInputField.value.length == 0) {
        errorMessage.textContent = "Too short username";
    }
    else {
        errorMessage.textContent = "";
        await insertNewUser(usernameInputField.value, passwordInputField.value, emailInputField.value);
        //window.location.replace("index.html");
    }
}

function insertNewUser(username, password, email) {
    var toSend = { type: "insertNewUser", username: username, password: password, email: email };
    socket.send(JSON.stringify(toSend));
}

function isUsernameTaken() {
    var toSend = { type: "isUsernameTaken", username: usernameInputField.value };
    socket.send(JSON.stringify(toSend));
    testFinished = false;
}

function isValidUsernamePassword() {
    var toSend = { type: "isValidUsernamePassword", username: usernameInputField.value, password: passwordInputField.value };
    socket.send(JSON.stringify(toSend));
}





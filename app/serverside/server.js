// Main program for the quote server
// To execute, cd to the serverSide directory and give command:
//   node server.js
//   - N. Wilde, July 2020

// Load my class that holds the set of quotations
const AllQuotes = require('./AllQuotes');
const QUOTE_DB_FILE = "../data/quotes_all.csv"

// Load and configure the Express web server
const express = require('express');
const app = express();
const port = 3000;

// Set the paths that express will recognize and assign a function
// to handle GET messages for each set of paths
app.get('/', (req, res) => res.send(getResponseHTML(null)));
app.get('/search', (req, res) => res.send(getResponseHTML(req.query.search_string)) );

app.listen(port, () => console.log(`Example app listening at http://localhost:${port}`));

// Function to process an input message and emit the response
// Input is sString - the search string to locate a quotation
// If null, just display "Please do a search"
function getResponseHTML(sString){
    console.log("Searched for: " + sString); // DEBUG
    if(!isSafe(sString)){
        sString = null;
    }
    // aQuote is a javascript object with the quote to return
    let aQuote = {"theText" : "Please do a search"};
    if ((null !== sString) && (sString.length > 0)) {
        let searcher = new AllQuotes();
        // Load the collection of quotes
        searcher.loadFromFile(QUOTE_DB_FILE);
        aQuote.theText = searcher.findQuote(sString);
    }
    // template is a shell for the HTML response message
    // The quote gets inserted and then the template is returned
    let template = `
    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
    <html>
        <head>
            <meta http-equiv="content-type" content="text/html; charset=UTF-8">
            <title>Quote Server Page</title>
        </head>
        <body>
            <h2>Quote Server</h2>
            <form action="/search">
                <label for="search_string">Search string:</label><br>
                <input type="text" id="search_string" name="search_string"><br> <br>
                <input type="submit" value="Submit Search">
            </form>
            <hr>
            <p style="font-size: 1.5em;">
            ${aQuote.theText}
            </p>
        </body>
        </html>`;
    return template;
} // end getResponseHTML()

// a too simple check for unsafe search strings
// We accept only alphanumeric and spaces.
function isSafe(s){
    pattern = /[^a-zA-Z0-9 ]/;
    return !pattern.test(s);
}

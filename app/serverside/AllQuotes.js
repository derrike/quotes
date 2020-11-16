// A class to search through a collection of quotes
// First load quotes using loadFromFile() or addQuote()
// Then search using findQuote
//   - N. Wilde, July 2020
class AllQuotes {
    quoteArray = [];

    addQuote(str) {
        this.quoteArray.push(str);
    } // end addQuote

    loadFromFile(thePath){
        // assume file has fields separated by ";"
        // the first field has the quote
        let fs = require('fs');
        let contents = fs.readFileSync(thePath, "utf8");
        let records = contents.split("\n");
        let numRecords = records.length;
        for(let j = 0; j < numRecords; j++){
            let aLine = records[j];
            // need to exclude the empty record produced by split
            if( aLine.length > 0) {
                let fields = aLine.split(";");
                this.addQuote(fields[0]);
            }
        }
    } // end loadFromFile

    findQuote(qString){
        let result = "No matching quote was found";
        this.quoteArray.forEach( (q) => {
            if (q.search(qString) > -1 ){
                // found a matching quote
                result = q;
            }
        } );
        return result;
    } // end findQuote()

} // end class AllQuotes
module.exports = AllQuotes;
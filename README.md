# Lithium

Demo: 

```javascript

const lithium = require('lithium.js')

lithium("./tests/truth-table.csv")
.solve([{ rule: null, P: "F", Q: "T", R: "T" }])
.then(res => console.log(JSON.stringify((res))))
```

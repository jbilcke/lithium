var Fussy = require('fussy');

console.log(
  new Fussy()
  .import('truth-table.csv', ['rule', 'P', 'Q', 'R'])
  .query({
    select: 'rule',
    where: [
        { P: 'T', Q: 'T', R: 'T' },
        { P: 'T', Q: 'F', R: 'F' },
        { P: 'F', Q: 'T', R: 'T' },
        { P: 'F', Q: 'F', R: 'T' }
    ]
  }).all()
)

var Fussy = require('fussy');

console.log(
  new Fussy()
  .import('truth-table.csv', [
      ['rule', 'String'],
      ['P',    'Number'],
      ['Q',    'Number'],
      ['R',    'Number']
    ])
  .query({
    select: 'rule',
    where: [
        { P: 4.2, Q: 4.2, R: 4.2 },
        { P: 4.2, Q: 6.6, R: 6.6 },
        { P: 6.6, Q: 4.2, R: 4.2 },
        { P: 6.6, Q: 6.6, R: 4.2 }
    ]
  }).all()
);

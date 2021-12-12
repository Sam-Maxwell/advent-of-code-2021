const { readFileSync } = require('fs');
const { each, filter, flow, join, map, range, reduce, split, size, tap } = require('lodash/fp');

STEPS = 2000
FLASH_POINT = 10

const gain = (energies, rows, columns, row, column) => {
  if (row < 0 || row > rows - 1 || column < 0 || column > columns - 1) return;
  energy = energies[row][column]
  if (energy >= FLASH_POINT) return;
  energy += 1
  energies[row][column] = energy
  if (energy < FLASH_POINT) return;
  gain(energies, rows, columns, row - 1, column - 1)
  gain(energies, rows, columns, row - 1, column)
  gain(energies, rows, columns, row - 1, column + 1)
  gain(energies, rows, columns, row, column - 1)
  gain(energies, rows, columns, row, column + 1)
  gain(energies, rows, columns, row + 1, column - 1)
  gain(energies, rows, columns, row + 1, column)
  gain(energies, rows, columns, row + 1, column + 1)
}

const reset = (energies, rows, columns, row, column) => {
  if (energies[row][column] < FLASH_POINT) return;
  energies[row][column] = 0;
}

// data = `5483143223
// 2745854711
// 5264556173
// 6141336146
// 6357385478
// 4167524645
// 2176841721
// 6882881134
// 4846848554
// 5283751526
// `;

data = readFileSync(`${__dirname}/data.txt`, 'utf-8');

flow([
  split('\n'),
  filter(x => x !== ''),
  map(x => map(Number.parseInt, split('', x))),
  (energies) => {
    rows = size(energies)
    columns = size(energies[0])

    flashes = 0

    each((step) => {
      each((row) => {
        each((column) => {
          gain(energies, rows, columns, row, column);
        }, range(0, columns))
      }, range(0, rows))

      const flashes_at_step = reduce((total, row) => {
        return total + reduce((subTotal, energy) => {
          return subTotal + (energy >=FLASH_POINT ? 1 : 0);
        }, 0, row)
      }, 0, energies);

      each((row) => {
        each((column) => {
          reset(energies, rows, columns, row, column);
        }, range(0, columns))
      }, range(0, rows))

      console.log(`after step: ${step}`);
      each((row) => console.log(join('', row)), energies);
      console.log(`flashes at step: ${flashes_at_step}`);
      flashes += flashes_at_step;
      if (flashes_at_step === rows * columns) {
        console.log('synchronous flash!')
        return false;
      }
    }, range(1, STEPS + 1))

    console.log(`flashes: ${flashes}`);
    return energies;
  },
  // tap(console.log),
])(data);

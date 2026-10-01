// Recipe products in Factorio 2.1 data: how many a craft gives on average, and the chance shown
// next to a product. 2.1 replaced `probability` with `independent_probability` (own roll) and
// `shared_probability` ({min, max} of one roll shared by the recipe's products), and adds
// `extra_count_fraction` (chance of one more).

// Chance that the product is given at all.
const chance = (p) => {
  const independent = p.independent_probability ?? p.probability ?? 1;
  const shared = p.shared_probability ? p.shared_probability.max - p.shared_probability.min : 1;
  return independent * shared;
};

// Average amount per craft.
const expected = (p) => {
  const base = p.amount ?? (Math.max(p.amount_min, p.amount_max ?? p.amount_min) + p.amount_min) / 2;
  return base * chance(p) + (p.extra_count_fraction ?? 0);
};

// "×3", "×1-3", with " (25%)" when the product is not certain.
const label = (p) => {
  const amount = p.amount ?? `${p.amount_min}-${p.amount_max}`;
  const c = chance(p);
  return `×${amount}${c < 1 ? `(${Number((c * 100).toFixed(2))}%)` : ''}${p.extra_count_fraction ? `(+${p.extra_count_fraction})` : ''}`;
};

module.exports = { chance, expected, label };

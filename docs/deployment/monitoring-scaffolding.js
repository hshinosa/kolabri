const threshold = parseInt(process.env.SCAFFOLDING_ALERT_THRESHOLD || '80', 10);

db.activity_logs.aggregate([
  {
    $match: {
      "Attributes.scaffolding_level": { $exists: true },
      Timestamp: { $gte: new Date(Date.now() - 24 * 3600000) }
    }
  },
  {
    $group: {
      _id: "$Attributes.scaffolding_level",
      count: { $sum: 1 }
    }
  },
  { $sort: { count: -1 } }
]).toArray().then(results => {
  const total = results.reduce((sum, r) => sum + r.count, 0);
  const disabled = results.find(r => r._id === 'disabled')?.count || 0;
  const disabledPct = total > 0 ? (disabled / total) * 100 : 0;

  print("Scaffolding distribution (last 24h):");
  results.forEach(r => print("  " + r._id + ": " + r.count));
  print("Total: " + total);
  print("Disabled %: " + disabledPct.toFixed(1) + "%");

  if (disabledPct > threshold) {
    print("ALERT: Disabled rate " + disabledPct.toFixed(1) + "% exceeds threshold " + threshold + "%");
  } else {
    print("Within threshold");
  }
});

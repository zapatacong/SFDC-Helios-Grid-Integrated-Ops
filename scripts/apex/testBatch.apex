// This line triggers the batch job immediately in your Scratch Org
Database.executeBatch(new VOLT_EfficiencyBatch());

// This "Cron" expression means: Run at 00:00 (Midnight) every day.
String cronExp = '0 0 0 * * ?'; 
System.schedule('Volt-Track: Daily Efficiency Scan', cronExp, new VOLT_EfficiencyScheduler());
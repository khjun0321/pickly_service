#!/usr/bin/env ts-node
/**
 * Cron Scheduler - Automated API Collection & Transformation
 * PRD v9.6.1 - Phase 4D Step 1
 *
 * Purpose: Schedule automatic API collection and data transformation
 *
 * Usage:
 *   npm run scheduler:run              - Start scheduler (runs daily at 3:00 AM)
 *   npm run scheduler:run -- --dry-run - Test mode (console only, no actual execution)
 *   npm run scheduler:run -- --now     - Execute immediately (for testing)
 *   npm run scheduler:run -- --help    - Show help
 */

import * as cron from 'node-cron'
import { spawn } from 'child_process'
import * as fs from 'fs'
import * as path from 'path'

interface CliOptions {
  dryRun: boolean
  now: boolean
  help: boolean
  schedule: string
}

interface ExecutionResult {
  success: boolean
  duration: number
  stdout: string
  stderr: string
  exitCode: number | null
}

/**
 * Parse CLI arguments
 */
function parseArgs(): CliOptions {
  const args = process.argv.slice(2)

  return {
    dryRun: args.includes('--dry-run'),
    now: args.includes('--now'),
    help: args.includes('--help') || args.includes('-h'),
    schedule: args.find(arg => arg.startsWith('--schedule='))?.split('=')[1] || '0 3 * * *',
  }
}

/**
 * Show CLI help
 */
function showHelp(): void {
  console.log(`
╔════════════════════════════════════════════════════════════════╗
║           ⏰ Pickly Cron Scheduler - Help                     ║
╚════════════════════════════════════════════════════════════════╝

Automatically run API collection and data transformation on a schedule.

USAGE:
  npm run scheduler:run [options]

OPTIONS:
  --dry-run              Test mode - console output only, no execution
  --now                  Execute immediately (for testing)
  --schedule="0 3 * * *" Custom cron schedule (default: 3:00 AM daily)
  --help, -h             Show this help message

EXAMPLES:
  # Start scheduler (runs at 3:00 AM daily)
  npm run scheduler:run

  # Test without actual execution
  npm run scheduler:run -- --dry-run

  # Execute immediately for testing
  npm run scheduler:run -- --now

  # Custom schedule (every hour)
  npm run scheduler:run -- --schedule="0 * * * *"

CRON SCHEDULE FORMAT:
  ┌───────────── minute (0 - 59)
  │ ┌───────────── hour (0 - 23)
  │ │ ┌───────────── day of month (1 - 31)
  │ │ │ ┌───────────── month (1 - 12)
  │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
  │ │ │ │ │
  * * * * *

COMMON SCHEDULES:
  "0 3 * * *"     - Daily at 3:00 AM
  "0 */6 * * *"   - Every 6 hours
  "0 0 * * 0"     - Every Sunday at midnight
  "*/30 * * * *"  - Every 30 minutes

WORKFLOW:
  1. Collect data from APIs (npm run collect:api)
  2. Transform raw data (npm run transform:api)
  3. Log results to backend/logs/scheduler.log

LOG FILE:
  backend/logs/scheduler.log

For more info: backend/services/scheduler/README.md
`)
}

/**
 * Execute a command and capture output
 */
async function executeCommand(
  command: string,
  args: string[],
  label: string
): Promise<ExecutionResult> {
  return new Promise((resolve) => {
    const startTime = Date.now()
    let stdout = ''
    let stderr = ''

    console.log(`\n${'='.repeat(60)}`)
    console.log(`▶️  Executing: ${label}`)
    console.log(`   Command: ${command} ${args.join(' ')}`)
    console.log(`${'='.repeat(60)}\n`)

    const child = spawn(command, args, {
      cwd: path.join(__dirname, '../..'),
      env: process.env,
      stdio: 'pipe',
    })

    child.stdout?.on('data', (data) => {
      const output = data.toString()
      stdout += output
      process.stdout.write(output)
    })

    child.stderr?.on('data', (data) => {
      const output = data.toString()
      stderr += output
      process.stderr.write(output)
    })

    child.on('close', (exitCode) => {
      const duration = Date.now() - startTime

      console.log(`\n${'='.repeat(60)}`)
      console.log(`${exitCode === 0 ? '✅' : '❌'} ${label} ${exitCode === 0 ? 'completed' : 'failed'}`)
      console.log(`   Duration: ${(duration / 1000).toFixed(2)}s`)
      console.log(`   Exit Code: ${exitCode}`)
      console.log(`${'='.repeat(60)}\n`)

      resolve({
        success: exitCode === 0,
        duration,
        stdout,
        stderr,
        exitCode,
      })
    })

    child.on('error', (error) => {
      const duration = Date.now() - startTime

      console.error(`❌ Failed to execute ${label}:`, error.message)

      resolve({
        success: false,
        duration,
        stdout,
        stderr: error.message,
        exitCode: null,
      })
    })
  })
}

/**
 * Write execution log to file
 */
function writeLog(message: string): void {
  const logDir = path.join(__dirname, '../../logs')
  const logFile = path.join(logDir, 'scheduler.log')

  // Create logs directory if it doesn't exist
  if (!fs.existsSync(logDir)) {
    fs.mkdirSync(logDir, { recursive: true })
  }

  const timestamp = new Date().toISOString()
  const logEntry = `[${timestamp}] ${message}\n`

  fs.appendFileSync(logFile, logEntry)
}

/**
 * Execute the scheduled job
 */
async function executeScheduledJob(options: { dryRun: boolean }): Promise<void> {
  const { dryRun } = options
  const startTime = Date.now()

  console.log(`\n╔════════════════════════════════════════════════════════════════╗`)
  console.log(`║           ⏰ Pickly Scheduled Job Execution                   ║`)
  console.log(`║              PRD v9.6.1 - Phase 4D Step 1                     ║`)
  console.log(`╚════════════════════════════════════════════════════════════════╝\n`)

  console.log(`⏰ Started at: ${new Date().toLocaleString()}`)
  console.log(`🧪 Dry Run: ${dryRun ? 'YES' : 'NO'}\n`)

  writeLog(`======= Scheduled Job Started (Dry Run: ${dryRun}) =======`)

  if (dryRun) {
    console.log(`🧪 [DRY RUN] Would execute:`)
    console.log(`   1. npm run collect:api`)
    console.log(`   2. npm run transform:api\n`)

    writeLog('DRY RUN: Simulated execution only')
    writeLog('======= Scheduled Job Completed (Dry Run) =======')

    return
  }

  try {
    // Step 1: Collect data from APIs
    const collectResult = await executeCommand('npm', ['run', 'collect:api'], 'API Collection')

    if (!collectResult.success) {
      const errorMsg = `API Collection failed with exit code ${collectResult.exitCode}`
      writeLog(`ERROR: ${errorMsg}`)
      writeLog(`STDERR: ${collectResult.stderr}`)
      writeLog('======= Scheduled Job Failed =======')

      console.error(`\n❌ Scheduled job failed: ${errorMsg}\n`)
      return
    }

    writeLog(`SUCCESS: API Collection completed in ${(collectResult.duration / 1000).toFixed(2)}s`)

    // Step 2: Transform raw data
    const transformResult = await executeCommand('npm', ['run', 'transform:api'], 'Data Transformation')

    if (!transformResult.success) {
      const errorMsg = `Data Transformation failed with exit code ${transformResult.exitCode}`
      writeLog(`ERROR: ${errorMsg}`)
      writeLog(`STDERR: ${transformResult.stderr}`)
      writeLog('======= Scheduled Job Partially Completed =======')

      console.error(`\n⚠️  Scheduled job partially completed: ${errorMsg}\n`)
      return
    }

    writeLog(`SUCCESS: Data Transformation completed in ${(transformResult.duration / 1000).toFixed(2)}s`)

    const totalDuration = Date.now() - startTime

    console.log(`\n╔════════════════════════════════════════════════════════════════╗`)
    console.log(`║                 📊 Execution Summary                          ║`)
    console.log(`╚════════════════════════════════════════════════════════════════╝\n`)

    console.log(`⏱️  Total Duration: ${(totalDuration / 1000).toFixed(2)}s`)
    console.log(`\n✅ API Collection: ${(collectResult.duration / 1000).toFixed(2)}s`)
    console.log(`✅ Data Transformation: ${(transformResult.duration / 1000).toFixed(2)}s`)
    console.log(`\n✅ All tasks completed successfully!\n`)

    writeLog(`SUCCESS: Total execution time ${(totalDuration / 1000).toFixed(2)}s`)
    writeLog('======= Scheduled Job Completed Successfully =======')

  } catch (error: any) {
    const errorMsg = error.message || 'Unknown error'
    writeLog(`FATAL ERROR: ${errorMsg}`)
    writeLog('======= Scheduled Job Failed =======')

    console.error(`\n❌ Fatal error: ${errorMsg}\n`)
    throw error
  }
}

/**
 * Main scheduler function
 */
async function startScheduler(): Promise<void> {
  const options = parseArgs()

  // Show help if requested
  if (options.help) {
    showHelp()
    process.exit(0)
  }

  console.log(`╔════════════════════════════════════════════════════════════════╗`)
  console.log(`║            ⏰ Pickly Cron Scheduler Started                   ║`)
  console.log(`║              PRD v9.6.1 - Phase 4D Step 1                     ║`)
  console.log(`╚════════════════════════════════════════════════════════════════╝\n`)

  console.log(`⏰ Current Time: ${new Date().toLocaleString()}`)
  console.log(`📅 Schedule: ${options.schedule}`)
  console.log(`🧪 Dry Run Mode: ${options.dryRun ? 'YES' : 'NO'}`)

  // Validate cron schedule
  if (!cron.validate(options.schedule)) {
    console.error(`\n❌ Invalid cron schedule: ${options.schedule}`)
    console.error(`   Use --help to see valid formats\n`)
    process.exit(1)
  }

  // Execute immediately if --now flag is set
  if (options.now) {
    console.log(`\n🚀 Executing immediately (--now flag)\n`)
    await executeScheduledJob({ dryRun: options.dryRun })
    console.log(`\n✅ Immediate execution completed\n`)
    process.exit(0)
  }

  // Schedule the job
  console.log(`\n✅ Scheduler initialized successfully`)
  console.log(`⏰ Next execution: ${getNextExecutionTime(options.schedule)}\n`)
  console.log(`📝 Logs: backend/logs/scheduler.log`)
  console.log(`\n💡 Press Ctrl+C to stop the scheduler\n`)

  writeLog(`Scheduler started with schedule: ${options.schedule}`)

  // Create cron job
  const job = cron.schedule(options.schedule, async () => {
    console.log(`\n⏰ Cron job triggered at ${new Date().toLocaleString()}\n`)
    await executeScheduledJob({ dryRun: options.dryRun })
  })

  // Handle graceful shutdown
  process.on('SIGINT', () => {
    console.log(`\n\n⏸️  Scheduler stopped by user`)
    writeLog('Scheduler stopped by user (SIGINT)')
    job.stop()
    process.exit(0)
  })

  process.on('SIGTERM', () => {
    console.log(`\n\n⏸️  Scheduler stopped (SIGTERM)`)
    writeLog('Scheduler stopped (SIGTERM)')
    job.stop()
    process.exit(0)
  })

  // Keep process running
  job.start()
}

/**
 * Get next execution time for display
 */
function getNextExecutionTime(schedule: string): string {
  const now = new Date()
  const parts = schedule.split(' ')

  if (parts.length !== 5) {
    return 'Unknown (invalid schedule)'
  }

  const [minute, hour] = parts

  if (minute === '*' && hour === '*') {
    return 'Every minute'
  }

  if (hour === '*') {
    return `Every hour at minute ${minute}`
  }

  const nextHour = parseInt(hour)
  const nextMinute = parseInt(minute)

  if (isNaN(nextHour) || isNaN(nextMinute)) {
    return `Custom schedule: ${schedule}`
  }

  const next = new Date(now)
  next.setHours(nextHour, nextMinute, 0, 0)

  if (next <= now) {
    next.setDate(next.getDate() + 1)
  }

  return next.toLocaleString()
}

// Run if executed directly
if (require.main === module) {
  startScheduler().catch(error => {
    console.error(`Fatal error:`, error)
    writeLog(`FATAL: ${error.message}`)
    process.exit(1)
  })
}

export default startScheduler

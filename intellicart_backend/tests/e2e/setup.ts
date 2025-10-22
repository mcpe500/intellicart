import fs from 'fs/promises';
import path from 'path';

const originalDbPath = path.resolve(process.cwd(), 'src/database/db.json.backup'); // Keep a clean backup
const testDbPath = path.resolve(process.cwd(), 'src/database/db.json'); // The live DB file

export async function setupE2ETestDb() {
    try {
        // Create backup if it doesn't exist
        try {
            await fs.access(originalDbPath);
        } catch {
            console.log("Creating db.json backup...");
            await fs.copyFile(testDbPath, originalDbPath);
        }
        // Restore from backup before each test/suite
        await fs.copyFile(originalDbPath, testDbPath);
        console.log("Restored test DB from backup.");
        
        // Re-initialize the db service instance to read the restored file
        const { initializeDb } = await import('../../src/database/db_service');
        await initializeDb(); // Re-initialize with the restored file
    } catch (error) {
        console.error('Error setting up E2E test DB:', error);
        throw new Error("Failed to set up E2E database.");
    }
}

export async function cleanupE2ETestDb() {
    // Optional: Restore backup after tests
    try {
        await fs.copyFile(originalDbPath, testDbPath); // Restore original state after tests
        console.log("Cleaned up E2E test DB.");
    } catch (error) {
        console.error('Error cleaning up E2E test DB:', error);
    }
}

// Export a function to reset the DB to initial state
export async function resetTestDb() {
    await fs.copyFile(originalDbPath, testDbPath);
    const { initializeDb } = await import('../../src/database/db_service');
    await initializeDb();
}
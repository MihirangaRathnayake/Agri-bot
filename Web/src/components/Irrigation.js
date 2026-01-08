import React, { useState, useEffect } from 'react';
import { motion } from 'framer-motion';
import { Power, Droplets } from 'lucide-react';
import { database } from '../firebase/config';
import { ref, onValue, off, get, set } from 'firebase/database';

const Irrigation = () => {
  const [pump1Status, setPump1Status] = useState(null);
  const [pump2Status, setPump2Status] = useState(null);
  const [isToggling, setIsToggling] = useState(false);
  const [statusLog, setStatusLog] = useState([]);

  // Function to add status log entry and prevent duplicates
  const addStatusLogEntry = (pumpNumber, status) => {
    const timestamp = new Date().toLocaleTimeString();
    const statusText = status === null ? 'Unknown' : status ? 'ON' : 'OFF';
    const newEntry = {
      id: Date.now(),
      pump: pumpNumber,
      status: statusText,
      timestamp: timestamp
    };

    setStatusLog(prevLog => {
      // Check if the last entry is the same as the new one
      const lastEntry = prevLog[prevLog.length - 1];
      if (lastEntry && lastEntry.pump === pumpNumber && lastEntry.status === statusText) {
        return prevLog; // Don't add duplicate
      }
      
      // Keep only the last 10 entries to prevent log from growing too large
      const updatedLog = [...prevLog, newEntry];
      return updatedLog.slice(-10);
    });
  };

  useEffect(() => {
    const pump1Ref = ref(database, "/soil/pump1");
    const pump2Ref = ref(database, "/soil/pump2");
    
    const unsubscribe1 = onValue(pump1Ref, (snapshot) => {
      const status = snapshot.val();
      console.log('Pump 1 status received:', status); // Debug log
      setPump1Status(status);
      addStatusLogEntry(1, status);
    }, (error) => {
      console.error('Error reading pump 1 status:', error);
      setPump1Status(null);
      addStatusLogEntry(1, null);
    });

    const unsubscribe2 = onValue(pump2Ref, (snapshot) => {
      const status = snapshot.val();
      console.log('Pump 2 status received:', status); // Debug log
      setPump2Status(status);
      addStatusLogEntry(2, status);
    }, (error) => {
      console.error('Error reading pump 2 status:', error);
      setPump2Status(null);
      addStatusLogEntry(2, null);
    });

    return () => {
      off(pump1Ref, 'value', unsubscribe1);
      off(pump2Ref, 'value', unsubscribe2);
    };
  }, []);

  const togglePump = async (pumpNumber) => {
    if (!isToggling) {
      setIsToggling(true);
      try {
        const pumpRef = ref(database, `/soil/pump${pumpNumber}`);
        const snapshot = await get(pumpRef);
        const current = snapshot.val();
        await set(pumpRef, !current);
        console.log(`Pump ${pumpNumber} toggled to:`, !current); // Debug log
      } catch (error) {
        console.error(`Error toggling pump ${pumpNumber}:`, error);
      } finally {
        setTimeout(() => setIsToggling(false), 1000);
      }
    }
  };

  return (
    <motion.section 
      initial={{ opacity: 0, y: 50 }}
      whileInView={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.8, delay: 0.2 }}
      viewport={{ once: true }}
      className="group backdrop-blur-xl bg-gradient-to-br from-dark-800/80 to-dark-700/60 border border-primary-500/20 rounded-3xl p-8 shadow-2xl hover:shadow-primary-500/10 transition-all duration-500 hover:scale-[1.02]" 
      id="irrigation"
    >
      <div className="flex items-center justify-between mb-8">
        <h2 className="text-3xl font-bold text-white flex items-center space-x-3">
          <motion.i 
            animate={{ 
              rotate: (pump1Status || pump2Status) ? [0, 360] : 0,
              scale: (pump1Status || pump2Status) ? [1, 1.1, 1] : 1
            }}
            transition={{ 
              rotate: { duration: 2, repeat: (pump1Status || pump2Status) ? Infinity : 0, ease: "linear" },
              scale: { duration: 1, repeat: Infinity, ease: "easeInOut" }
            }}
            className="fas fa-tint text-4xl text-blue-400"
          />
          <span>Water Pumps</span>
        </h2>
        <motion.div 
          className={`px-4 py-2 rounded-full text-sm font-medium flex items-center space-x-2 ${
            (pump1Status === null && pump2Status === null) ? 'bg-gray-500/20 text-gray-400' :
            (pump1Status || pump2Status) ? 'bg-blue-500/20 text-blue-400' : 'bg-gray-500/20 text-gray-400'
          }`}
        >
          <motion.div 
            animate={{ scale: (pump1Status || pump2Status) ? [1, 1.2, 1] : 1 }}
            transition={{ duration: 1, repeat: (pump1Status || pump2Status) ? Infinity : 0 }}
            className={`w-2 h-2 rounded-full ${
              (pump1Status === null && pump2Status === null) ? 'bg-gray-400' :
              (pump1Status || pump2Status) ? 'bg-blue-400' : 'bg-gray-400'
            }`}
          />
          <span>
            {(pump1Status === null && pump2Status === null) ? '--' : 
             (pump1Status || pump2Status) ? 'Active' : 'Inactive'}
          </span>
        </motion.div>
      </div>
      
      <div className="space-y-6">
        {/* Pump 1 Controls */}
        <div className="space-y-4">
          <h3 className="text-xl font-semibold text-white text-center">Pump 1 (Sensor 1)</h3>
          <motion.button 
            onClick={() => togglePump(1)}
            disabled={isToggling}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className={`w-full py-4 px-8 rounded-2xl font-semibold text-lg shadow-lg transition-all duration-300 flex items-center justify-center space-x-3 ${
              isToggling 
                ? 'bg-gray-500 cursor-not-allowed' 
                : pump1Status 
                  ? 'bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 hover:shadow-red-500/25' 
                  : 'bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 hover:shadow-blue-500/25'
            } text-white`}
          >
            {isToggling ? (
              <>
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="w-6 h-6 border-2 border-white border-t-transparent rounded-full"
                />
                <span>Processing...</span>
              </>
            ) : (
              <>
                <Power className="w-6 h-6" />
                <span>{pump1Status ? 'Turn OFF Pump 1' : 'Turn ON Pump 1'}</span>
              </>
            )}
          </motion.button>
        </div>

        {/* Pump 2 Controls */}
        <div className="space-y-4">
          <h3 className="text-xl font-semibold text-white text-center">Pump 2 (Sensor 2)</h3>
          <motion.button 
            onClick={() => togglePump(2)}
            disabled={isToggling}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className={`w-full py-4 px-8 rounded-2xl font-semibold text-lg shadow-lg transition-all duration-300 flex items-center justify-center space-x-3 ${
              isToggling 
                ? 'bg-gray-500 cursor-not-allowed' 
                : pump2Status 
                  ? 'bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 hover:shadow-red-500/25' 
                  : 'bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 hover:shadow-blue-500/25'
            } text-white`}
          >
            {isToggling ? (
              <>
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="w-6 h-6 border-2 border-white border-t-transparent rounded-full"
                />
                <span>Processing...</span>
              </>
            ) : (
              <>
                <Power className="w-6 h-6" />
                <span>{pump2Status ? 'Turn OFF Pump 2' : 'Turn ON Pump 2'}</span>
              </>
            )}
          </motion.button>
        </div>

        {/* Status Log */}
        <div className="bg-dark-800/50 rounded-2xl p-6 border border-gray-700/50">
          <h4 className="text-lg font-semibold text-white mb-4 text-center">Pump Status Log</h4>
          <div className="space-y-2 max-h-48 overflow-y-auto">
            {statusLog.length === 0 ? (
              <p className="text-gray-400 text-center py-4">No status updates yet</p>
            ) : (
              statusLog.map((entry) => (
                <motion.div
                  key={entry.id}
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ duration: 0.3 }}
                  className="flex items-center space-x-3 py-2 px-3 rounded-lg bg-dark-700/30"
                >
                  <Droplets className={`w-4 h-4 ${
                    entry.status === 'Unknown' ? 'text-gray-400' :
                    entry.status === 'ON' ? 'text-blue-400' : 'text-gray-400'
                  }`} />
                  <span className="text-sm text-gray-300">
                    Pump {entry.pump} Status: {' '}
                    <span className={`font-semibold ${
                      entry.status === 'Unknown' ? 'text-gray-400' :
                      entry.status === 'ON' ? 'text-blue-400' : 'text-gray-400'
                    }`}>
                      {entry.status}
                    </span>
                  </span>
                  <span className="text-xs text-gray-500 ml-auto">
                    {entry.timestamp}
                  </span>
                </motion.div>
              ))
            )}
          </div>
        </div>

        {/* Visual pump animations */}
        <div className="flex justify-center space-x-8 mt-8">
          {/* Pump 1 Animation */}
          <div className="relative">
            <motion.div
              animate={pump1Status ? {
                scale: [1, 1.1, 1],
                opacity: [0.5, 1, 0.5]
              } : {}}
              transition={{
                duration: 1.5,
                repeat: pump1Status ? Infinity : 0,
                ease: "easeInOut"
              }}
              className={`w-16 h-16 rounded-full border-4 flex items-center justify-center ${
                pump1Status ? 'border-blue-400 bg-blue-500/20' : 'border-gray-500 bg-gray-500/20'
              }`}
            >
              <motion.div
                animate={pump1Status ? { rotate: 360 } : {}}
                transition={{
                  duration: 2,
                  repeat: pump1Status ? Infinity : 0,
                  ease: "linear"
                }}
              >
                <Droplets className={`w-6 h-6 ${pump1Status ? 'text-blue-400' : 'text-gray-400'}`} />
              </motion.div>
            </motion.div>
            
            {pump1Status && (
              <motion.div
                animate={{
                  scale: [1, 1.5, 1],
                  opacity: [0.3, 0, 0.3]
                }}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                  ease: "easeOut"
                }}
                className="absolute inset-0 rounded-full border-2 border-blue-400"
              />
            )}
          </div>

          {/* Pump 2 Animation */}
          <div className="relative">
            <motion.div
              animate={pump2Status ? {
                scale: [1, 1.1, 1],
                opacity: [0.5, 1, 0.5]
              } : {}}
              transition={{
                duration: 1.5,
                repeat: pump2Status ? Infinity : 0,
                ease: "easeInOut"
              }}
              className={`w-16 h-16 rounded-full border-4 flex items-center justify-center ${
                pump2Status ? 'border-green-400 bg-green-500/20' : 'border-gray-500 bg-gray-500/20'
              }`}
            >
              <motion.div
                animate={pump2Status ? { rotate: 360 } : {}}
                transition={{
                  duration: 2,
                  repeat: pump2Status ? Infinity : 0,
                  ease: "linear"
                }}
              >
                <Droplets className={`w-6 h-6 ${pump2Status ? 'text-green-400' : 'text-gray-400'}`} />
              </motion.div>
            </motion.div>
            
            {pump2Status && (
              <motion.div
                animate={{
                  scale: [1, 1.5, 1],
                  opacity: [0.3, 0, 0.3]
                }}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                  ease: "easeOut"
                }}
                className="absolute inset-0 rounded-full border-2 border-green-400"
              />
            )}
            <div className="text-center mt-2 text-xs text-gray-400">Pump 2</div>
          </div>
        </div>
      </div>
    </motion.section>
  );
};

export default Irrigation;
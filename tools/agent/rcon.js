// Minimal Source RCON client for the Factorio server (one command per connection is enough).
const net = require('net');
const fs = require('fs');

const HOST = '127.0.0.1';
const PORT = Number(process.env.PT_RCON_PORT || 27115);
const PASSWORD_FILE = 'C:\\tmp\\cf-agent\\rcon-password.txt';

function packet(id, type, body) {
  const b = Buffer.from(body, 'utf8');
  const p = Buffer.alloc(14 + b.length);
  p.writeInt32LE(10 + b.length, 0);
  p.writeInt32LE(id, 4);
  p.writeInt32LE(type, 8);
  b.copy(p, 12);
  return p;
}

// Sends each command in order and resolves with their answers (strings).
function send(commands, { timeout = 60000 } = {}) {
  const password = fs.readFileSync(PASSWORD_FILE, 'utf8').trim();
  return new Promise((resolve, reject) => {
    const sock = net.connect(PORT, HOST);
    let buf = Buffer.alloc(0);
    const answers = [];
    let next = 0;
    const timer = setTimeout(() => { sock.destroy(); reject(new Error('rcon timeout')); }, timeout);
    const fail = (e) => { clearTimeout(timer); sock.destroy(); reject(e); };
    sock.on('error', fail);
    sock.on('connect', () => sock.write(packet(1, 3, password)));
    const sendNext = () => {
      if (next >= commands.length) { clearTimeout(timer); sock.end(); resolve(answers); return; }
      sock.write(packet(100 + next, 2, commands[next]));
    };
    sock.on('data', (chunk) => {
      buf = Buffer.concat([buf, chunk]);
      while (buf.length >= 4) {
        const size = buf.readInt32LE(0);
        if (buf.length < size + 4) break;
        const id = buf.readInt32LE(4);
        const type = buf.readInt32LE(8);
        const body = buf.toString('utf8', 12, size + 2);
        buf = buf.subarray(size + 4);
        if (type === 2 && id === -1) return fail(new Error('rcon authentication failed'));
        if (type === 2 && id === 1) { sendNext(); continue; }
        if (type === 0 && id === 100 + next) { answers.push(body); next += 1; sendNext(); }
      }
    });
  });
}

module.exports = { send };

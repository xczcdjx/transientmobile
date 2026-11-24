// Exercise the actual ArkTS task methods with mocked Harmony APIs.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const path = require('node:path');
const source = fs.readFileSync(path.join(__dirname, '../audio_service_ohos/ohos/src/main/ets/AudioService.ets'), 'utf8');
const methods = source.slice(source.indexOf('  startContinuousTask()'), source.indexOf('  // 创建session'))
  .replaceAll(': Promise<void>', '').replaceAll(': wantAgent.WantAgentInfo', '')
  .replaceAll(': BusinessError', '').replaceAll('new Promise<void>', 'new Promise');
function setup(start, stop = async () => {}) {
  const events = [];
  const Task = vm.runInNewContext(`(class {
    ability = { context: { abilityInfo: { bundleName: 'test', name: 'EntryAbility' } } };
    isStartContinuousTask = false;
    wantsContinuousTask = false;
    continuousTaskQueue = Promise.resolve();
    ${methods}
  })`, {
    backgroundTaskManager: { BackgroundMode: { AUDIO_PLAYBACK: 1 },
      startBackgroundRunning: async () => { events.push('start'); await start(); },
      stopBackgroundRunning: async () => { events.push('stop'); await stop(); } },
    wantAgent: { OperationType: { START_ABILITY: 1 }, WantAgentFlags: { UPDATE_PRESENT_FLAG: 1 }, getWantAgent: async () => ({}) },
    Log: { i() {}, e() {} }, TAG: 'test', setTimeout: (fn) => setTimeout(fn, 0)
  });
  return { task: new Task(), events };
}
(async () => {
  let attempts = 0;
  let { task, events } = setup(async () => { if (++attempts < 2) throw Error('transient'); });
  await task.startContinuousTask();
  assert.equal(attempts, 2);
  assert.equal(task.isStartContinuousTask, true);
  await task.startContinuousTask();
  assert.equal(attempts, 2, 'Repeated play must not duplicate an active request');
  await task.stopContinuousTask();
  assert.equal(task.isStartContinuousTask, false);

  attempts = 0;
  ({ task } = setup(async () => { if (++attempts <= 3) throw Error('failed'); }));
  await task.startContinuousTask();
  assert.equal(attempts, 3);
  assert.equal(task.isStartContinuousTask, false);
  await task.startContinuousTask();
  assert.equal(task.isStartContinuousTask, true, 'A failed request must remain retryable');

  let entered;
  let finish;
  const started = new Promise(resolve => { entered = resolve; });
  const pending = new Promise(resolve => { finish = resolve; });
  ({ task, events } = setup(async () => { entered(); await pending; }));
  const play = task.startContinuousTask();
  await started;
  const pause = task.stopContinuousTask();
  finish();
  await Promise.all([play, pause]);
  assert.deepEqual(events, ['start', 'stop']);
  assert.equal(task.isStartContinuousTask, false, 'Pause during startup must stop the completed task');

  let stops = 0;
  ({ task } = setup(async () => {}, async () => { if (++stops === 1) throw Error('stop failed'); }));
  await task.startContinuousTask();
  await task.stopContinuousTask();
  assert.equal(task.isStartContinuousTask, true);
  await task.stopContinuousTask();
  assert.equal(task.isStartContinuousTask, false);
  console.log('PASS: retry, duplicate start, failure recovery, in-flight pause, stop retry');
})().catch(e => { console.error(e); process.exitCode = 1; });

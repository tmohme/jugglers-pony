use "collections"
use "random"
use "time"

class ReportToConductorNotifier is TimerNotify
  let _juggler: Juggler
  let _env: Env
  let _id: U64

  new iso create(juggler: Juggler tag, env: Env val, id: U64 val) =>
    _juggler = juggler
    _env = env
    _id = id

  fun ref apply(timer: Timer ref, count: U64 val):Bool val =>
//    _env.out.print(_id.string() + ": ReportToConductorNotifier.apply, count=" + count.string())
    _juggler.reportToConductor()
    true


actor Juggler is TimerNotify
  let _env: Env val
  let _conductor: Main tag
  let _id: U64 val
  let _partners: List[Juggler] = List[Juggler]()
  let _dice: Dice = Dice(MT())
  let _timers: Timers = Timers
  var _stop: Bool = false

  var _caught: U64 = 0

  new create(env: Env val, conductor: Main tag, id: U64 val) =>
    _conductor = conductor
    _env = env
    _id = id

    let ten_millis = U64(10000000)
    let notifier = recover iso ReportToConductorNotifier(this, env, id) end
    let timer = Timer.create(consume notifier, ten_millis, ten_millis)
    _timers(consume timer)
//    env.out.print("created Juggler " + id.string())

  be setPartners(partners: List[Juggler] val) =>
//    _env.out.print(_id.string() + ": appending " + partners.size().string() + " partners")
    _partners.append(partners)

  be catchBall() =>
//    _env.out.print(_id.string() + ": caught ball")
    _caught = _caught + 1

    if (not _stop) then
      let receiver = _dice(1, _partners.size()) - 1
//      _env.out.print(_id.string() + ": caught " + _caught.string() + " balls, throwing to " + receiver.string())
      try
        _partners(receiver).catchBall()
      else
        _env.out.print(_id.string() + ": failed throwing ball to " + receiver.string())
      end
    end

  be reportToConductor() =>
//    _env.out.print(_id.string() + ":  reporting to conductor " + _caught.string())
    _conductor.caughtBalls(_caught)
    _caught = 0

  be stop() =>
//    _env.out.print(_id.string() + ":  stopping")
    _stop = true
    _timers.dispose()




class ReportToUserNotifier is TimerNotify
  let _conductor: Main
  let _env: Env

  new create(conductor: Main tag, env: Env) =>
    _conductor = conductor
    _env = env

  fun ref apply(timer: Timer ref, count: U64 val):Bool val =>
//    _env.out.print("ReportToUserNotifier.apply, count=" + count.string())
    _conductor.reportToUser()
    true


actor Main
  let _iterations:U64 val = 25
  let _env: Env val
  var _jugglerCount: U64 val = 0
  var _jugglers: List[Juggler] val = recover val List[Juggler]() end
  var _ballCount:U64 = 0
  var _caught: U64 val = 0
  var _toGo: U64 = _iterations
  let _timers: Timers = Timers

  new create(env: Env val) =>
    _env = env
    (_jugglerCount, _ballCount) = parse_args(_env)

    try
      let count: U64 val = _jugglerCount
      _jugglers = recover val
        let jugglers': List[Juggler] = List[Juggler]()
        // create jugglers
        for i in Range[U64](0, count) do
          let juggler = Juggler(env, this, i)
          jugglers'.push(juggler)
        end
        jugglers'
      end
      _start_messaging(_env)
    else
      usage(_env)
    end


  fun ref _start_messaging(env: Env) ? =>
    // tell them their partners
    for juggler in _jugglers.nodes() do
      juggler().setPartners(_jugglers)
    end

    _env.out.print("Running with " + _jugglers.size().string() + " jugglers thru " + _iterations.string() + " iterations, injecting " + _ballCount.string() + " balls each round.")

    // start the juggling
    _injectBalls(_jugglers(0), _ballCount)

    let one_second:U64 = 1000000000
    let notifier = recover iso ReportToUserNotifier(this, env) end
    let timer = Timer.create(consume notifier, one_second, one_second)
    _timers(consume timer)


  fun _injectBalls(juggler: Juggler tag, ballCount: U64) =>
    for n in Range[U64](0, ballCount) do
      juggler.catchBall()
    end


  be caughtBalls(count: U64) =>
    _caught = _caught + count


  be reportToUser() =>
    _env.out.print("caught: " + _caught.string())
    _caught = 0

    _toGo = _toGo - 1
    if (_toGo > 0) then
//      _env.out.print("injecting " + _ballCount.string() + " balls")
      try
        _injectBalls(_jugglers(0), _ballCount)
      end
    else
      // orderly shutdown . . .
      for juggler in _jugglers.nodes() do
        try
          juggler().stop()
        end
      end
      _timers.dispose()
    end


  fun tag parse_args(env: Env):(U64, U64) =>
    (
      try env.args(1).u64() else 8 end,
      try env.args(2).u64() else 8 end
    )

  fun tag usage(env: Env) =>
    env.out.print(
      """
      jugglers OPTIONS
        N   number of Jugglers
      """
      )

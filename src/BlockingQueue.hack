namespace BlockingQueue;

require_once(__DIR__."/../vendor/autoload.hack");

use namespace HH\lib\{C, PseudoRandom, Vec};
use namespace HH\Asio;

class BlockingQueue<T> {
  private vec<T> $list;
  private int $limit;

  public function __construct(int $limit) {
    $this->list = vec[];
    $this->limit = $limit;
  }

  public async function enqueueAsync(T $val): Awaitable<void> {
    while (C\count($this->list) === $this->limit) {
      /* HHAST_IGNORE_ERROR[DontAwaitInALoop] */
      await Asio\later();
    }
    $this->list[] = $val;
    print("Added Value: ".$val."\n");
  }

  public async function dequeueAsync(): Awaitable<T> {
    while (C\count($this->list) === 0) {
      /* HHAST_IGNORE_ERROR[DontAwaitInALoop] */
      await Asio\later();
    }
    $return_val = C\last($this->list);
    $length = C\count($this->list);
    $this->list = Vec\take($this->list, $length - 1);
    print("Popped Value: ".$return_val."\n");
    return $return_val;
  }
}

// used to test implementation
<<__EntryPoint>>
function main(): noreturn {
  \Facebook\AutoloadMap\initialize();
  $queue = new BlockingQueue<int>(5);
  while (true) {
    $random_number_to_add = PseudoRandom\int(1, 100);
    $is_add_oper = PseudoRandom\int(1, 2) === 1;
    if ($is_add_oper) {
      $queue->enqueueAsync($random_number_to_add);
    } else {
      $queue->dequeueAsync();
    }
  }
  exit(0);
}

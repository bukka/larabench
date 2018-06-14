<?php

namespace App\Http\Controllers;

use Psr\Log\LoggerInterface;

class LogController extends Controller
{
    const DEFAULT_SIZE = 1024;

    const CHAR = 'x';

    /**
     * @var LoggerInterface
     */
    private $logger;

    /**
     * LogController constructor.
     *
     * @param LoggerInterface $logger
     */
    public function __construct(LoggerInterface $logger)
    {
        $this->logger = $logger;
    }

    /**
     * Log message.
     *
     * @param string $level
     * @param int $size
     * @return \Illuminate\Http\JsonResponse
     */
    public function log($level, $size = self::DEFAULT_SIZE)
    {
        $message = str_repeat(self::CHAR, $size);
        if ($level === 'repeat') {
            for ($i = 1; $i < 1000; $i++) {
                $this->logger->log('error', $message);
            }
        } else {
            $this->logger->log($level, $message);
        }

        return response()->json(
            [
                'level' => $level,
                'char' => self::CHAR,
                'multiplier' => $size
            ]
        );
    }
}

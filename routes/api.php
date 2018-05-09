<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});

/*
 * Logging related path for bench mark
 */

// Basic callback path error logging using Facade
Route::get('/log/basic/{size?}', function ($size = 1024) {
    Log::error(str_repeat('a', $size));
    return 'done';
});

// Custom logging in the controller
Route::get('/log/custom/{type}/{size?}', 'LogController@log');
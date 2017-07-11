<?php

$approot = dirname(__FILE__) . '/../..';
$dnaroot = $approot . '/../../dna';
$root = $dnaroot . '/..';

// to mark that we are running tests
define('TESTING', true);

// include bootstrap
require_once("$approot/bootstrap.php");

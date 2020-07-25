<?php
/**
 * Helper script to inject a user to a configured writeable backend
 * 
 * This is supposed to be placed in horde/bin dir
 * This will not meddle with the $conf['auth']['admin'] settings
 */
require_once dirname(__FILE__) . '/../lib/Application.php';
Horde_Registry::appInit('horde', array('authentication' => 'none'));

$auth = $injector->getInstance('Horde_Core_Factory_Auth')->create();

$password = $argv[2] ?? 'administrator';
$user = $argv[1] ?? 'administrator';

$auth->addUser('administrator', array('password' => 'administrator'));

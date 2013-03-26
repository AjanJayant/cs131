#!/usr/bin/python

import time
import datetime
import sys

from twisted.internet.protocol import Factory, ClientFactory, ReconnectingClientFactory
from twisted.protocols.basic import LineReceiver
from twisted.internet import reactor
from twisted.internet.endpoints import TCP4ClientEndpoint, TCP4ServerEndpoint
from twisted.internet.defer import Deferred
from twisted.internet.protocol import Protocol
from twisted.python import log
from twisted.web.client import Agent
from twisted.web.http_headers import Headers
from twisted.internet import reactor
from twisted.web.client import getPage
from twisted.python.util import println


def sendPeer(protocol, message_to_pass):

	protocol.send_message(message_to_pass)

class ServerProtocol(LineReceiver):

	def __init__(self, factory):

		self.factory = factory

	def lineReceived(self, message):

		self.factory.logInfo('Received message: {0}'.format(message))

		if message.startswith('IAMAT'):
			self.handleIAMAT(message)
		elif message.startswith('WHATSAT'):
			self.handleWHATSAT(message)
		elif message.startswith('PEER'):
			self.handlePEER(message)
		else:
			self.handleError(message)
	
				
	def handleIAMAT(self, message):

		if len(message.split()) != 4:
			self.factory.logError('IAMAT: incorrect number of arguements {0}'.format(message))
			self.handleError(message)
			return

		command, client, location, posixTime = message.split()

		try:
			posixTime = float(posixTime)
			clientTime = datetime.datetime.utcfromtimestamp(posixTime)
		except Exception as e:
			self.factory.logError('IAMAT: incorrect time {0}'.format(posixTime))
			self.handleError(message)
			return
			
		systemTime = datetime.datetime.utcnow()
		timeDiff = systemTime - clientTime
		
		self.factory.users[client] = (location, clientTime, systemTime)
		locationMessage = 'AT {0} {1!r} {2}'.format(self.factory.server_name, timeDiff.total_seconds(), ' ') + client + str(location) + ' ' + str(posixTime)
		self.sendMessage(locationMessage)

		self.factory.logInfo('Number of peers: {0}'.format(len(self.factory.peers.keys())))
		for peer in self.factory.peers.keys():
			self.factory.logInfo('Sending location information to peer: {0}'.format(peer))
			peerInfo = self.factory.peers[peer]
			peer, protocol, host, port = peerInfo
			self.factory.logInfo('Peer info: {0} {1} {2} {3}'.format(peer, protocol, host, port))

			end_point = None
			if protocol == 'tcp':
				end_point = TCP4ClientEndpoint(reactor, host, port)
				self.factory.logInfo('Endpoint created: {0!s}'.format(end_point))
				self.factory.logInfo('Connecting to peer: {0} {1} {2} {3}'.format(peer, protocol, host, port))
				connection = end_point.connect(self)
				connection.addCallback(sendPeer, locationMessage)

	def handleWHATSAT(self, message):
	
		if len(message.split()) != 4:
			self.factory.logError('WHATSAT: incorrect number of arguements {0}'.format(message))
			self.handleError(message)
			return

		command, client, radius, maxTweets = message.split()

		try:
			radius = float(radius)
			maxTweets = int(maxTweets)
		except Exception as e:
			self.factory.logError('WHATSAT command has malformed arguements: {0}'.format(message))
			self.handleError(message)
			return
			
		if not self.factory.users.has_key(client):
			self.factory.logError('Unable to find user: {0}'.format(client))
			self.handleError(message)
			return

		clientInfo = self.factory.users[client]
		location, clientTime, systemTime = clientInfo
		
		timeDiff = systemTime -clientTime

		self.sendMessage('AT {0} {1!r} {2} {3} {4}\n{5}'.format(self.factory.server_name, timeDiff.total_seconds(), client, str(location), str(clientTime), self.findTweets(location, radius, maxTweets)))
                   

	def handlePEER(self, message):

		tokens = message.split()

		if not len(tokens) == 5:
			self.factory.logError('PEER command malformed: {0}'.format(message))
			self.handleError(message)
			return

		command, peer, protocol, host, port = tokens

		try:
			port = int(port)
		except Exception as e:
			self.factory.logError('PEER command has malformed port number: {0}'.format(command))
			self.handleError(command)
			return

		if self.factory.peers.has_key(peer):
			self.factory.logInfo('Peer already exists: {0}'.format(peer))
		else:
			self.factory.peers[peer] = (peer, protocol, host, port)

			self.factory.logInfo('Connecting with peer: {0}'.format(peer))
			end_point = None
			if protocol == 'tcp':
				end_point = TCP4ServerEndpoint(reactor, host, port)
				self.factory.logInfo('Endpoint created: {0!s}'.format(end_point))
				self.factory.logInfo('Connecting to peer: {0} {1} {2} {3}'.format(peer, protocol, host, port))
				connection = end_point.listen(self)
				connection.addCallback(sendPeer, 'PEER {0} tcp {1} {2}'.format(self.factory.server_name, self.factory.host_name, self.factory.port_number))

		self.factory.logInfo('Number of peers: {0}'.format(len(self.peers.keys())))

	def handleError(self, command):

		self.sendMessage('?: {0}'.format(command))
		
	def sendMessage(self, message):

		self.sendLine(message)
		self.factory.logInfo('Sent message: {0}'.format(message))
		self.transport.loseConnection()
		
	def findTweets(self, client_location, radius_km, max_num_of_tweets):

		url = "http://search.twitter.com/search.json?"
		url += "geocode=" + client_location + ',' + str(radius_km) + 'km' # geo data
		url += '&rpp=' + str(max_num_of_tweets) + '&result_type=mixed'       # num tweets
		getPage(url).addCallbacks(
            callback = lambda value:(self.gotTweets(value, client, p)))
            
	def connectionMade(self):

		self.factory.logInfo('Connection made: {0}'.format(self.transport.getHost()))

	def connectionLost(self, reason):

		self.factory.logInfo('Connection lost.')




class Server(Factory):

	def __init__(self, server_name, host_name, port_number):

		self.server_name = server_name
		self.host_name = host_name
		self.port_number = port_number
		self.users = {}
		self.peers = {}
		self.log_stream = open('{0}_{1}.log'.format(self.server_name, datetime.datetime.utcnow().isoformat().replace(':', '_').replace('T', '_')), 'w')
		self.logInfo('Server opening.')

	def stopFactory(self):

		self.logInfo('Server closing.')
		self.log_stream.close()

	def buildProtocol(self, addr):

		self.logInfo('Protocol built for address: {0!s}'.format(addr))
		return ServerProtocol(self)

	def logInfo(self, message):

		self._log('INFO: {0!s}'.format(message))

	def logError(self, message):

		self._log('ERROR: {0!s}'.format(message))

	def _log(self, message):

		message = '{0}: {1}: {2}'.format(self.server_name, datetime.datetime.utcnow().isoformat(), message)
		print(message)
		try:
			self.log_stream.write(message+'\n')
		except ValueError as e:
			print('Could not log to file, file stream has been closed.')
			
if __name__ == '__main__':
	if(len(sys.argv) != 4):
		print "Incorrect number of command line arguemnts"
		exit()
	server = Server(sys.argv[1], sys.argv[2], int(sys.argv[3]))
	reactor.listenTCP(int(sys.argv[3]), server)
	reactor.run()
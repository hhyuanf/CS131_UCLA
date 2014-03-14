import datetime
import sys
import os
from twisted.protocols.basic import LineReceiver
from twisted.internet.protocol import Factory, Protocol, ReconnectingClientFactory
from twisted.internet import reactor
from twisted.internet.endpoints import TCP4ClientEndpoint
from twisted.internet.defer import Deferred

class Chat(LineReceiver):
    def __init__(self, factory):
        self.factory = factory
    
    def connectionMade(self):
        logInfo('success', 'Got new client!' + ' ' + str(self.transport.getHost()), self.factory)
    
    def connectionLost(self, reason):
        logInfo('success', 'Lost a client!' + ' ' + reason.getErrorMessage(), self.factory)
    
    def lineReceived(self, line):
        
        message = line.strip().split()
        
        logInfo('success', 'Message Received:' + ' ' + line, self.factory)
        
        if message[0] == 'IAMAT':
            self.handle_IAMAT(line)
        elif message[0] == 'WHATSAT':
            self.handle_WHATSAT(line)
        elif message[0] == 'AT':
            self.handle_AT(line)
        else:
            self.handle_ERROR(line)
                
    def handle_IAMAT(self, line):
        message = line.strip().split()
        if len(message) != 4:
            self.factory.logERR('IAMAT: arguments number is wrong' + ' ' + line)
            self.handle_ERROR(line)
            return
        client_name = message[1]
        client_location = message[2]
        client_time = float(message[3])

        try:
            time = datetime.datetime.utcfromtimestamp(client_time)
        except Exception as e:
            self.factory.logERR('IAMAT: time format is wrong' + ' ' + line)
            self.handle_ERROR(line)
            return
        time_now = datetime.datetime.utcnow()
        time_diff = time_now - time
        if (time_now > time):
            time_diff = '+' + str(time_diff.total_seconds())
        else:
            time_diff = '-' + str(time_diff.total_seconds())
        self.factory.users[client_name] = (client_location, time, time_diff, self.factory.server)
        locationMessage = 'AT' + ' ' + str(self.factory.server) + ' ' + time_diff + ' ' + client_name + ' ' + str(client_location) + ' ' + str(client_time)
        peerMessage = locationMessage + ' ' + str(self.factory.server)
        self.message(locationMessage)
        for peer in self.factory.peers.keys():
            info = self.factory.peers[peer]
            logInfo('success', 'IAMAT: Sending information to peer:' + ' ' + peer, self.factory)
            peer_host = info[0]
            peer_port = info[1]
            connecttcp('success', peer_port, peer, peer_host, peerMessage, self.factory)
            logInfo('success', 'IAMAT: Connecting to peer:' + ' ' + peer + ' ' + peer_host + ' ' + str(peer_port), self.factory)

    def handle_WHATSAT(self, line):
        message = line.strip().split()
        if len(message) != 4:
            self.factory.logERR('WHATSAT: arguments number is wrong' + ' ' + line)
            self.handle_ERROR(line)
            return
        client_name = message[1]
        client_radius = message[2]
        num_tweets = message[3]
        if int(num_tweets) > 100:
            self.factory.logERR('WHATSAT: Number of reqeusted tweets should be less than 100' + ' ' + line)
            self.handle_ERROR(line)
            return
        if not self.factory.users.has_key(client_name):
            self.factory.logERR('WHATSAT: Unable to locate user' + ' ' + line)
            self.handle_ERROR(line)
            return
        info = self.factory.users[client_name]
        self.message('AT' + ' ' + info[3] + ' ' + str(info[2]) + ' ' + client_name + ' ' + str(info[0]) + ' ' + str(info[1]) + '\n' + self.tweets(info[0], client_radius, num_tweets))
        logInfo('success', 'WHATSAT: Tweets have been sent to user' + ' ' + client_name, self.factory)
    
    def handle_AT(self, line):
        message = line.strip().split()
        if len(message) != 7:
            self.factory.logERR('AT: arguments number is wrong' + ' ' + line)
            self.handle_ERROR(line)
            return
        server_name = message[1]
        client_time_diff = message[2]
        client_name = message[3]
        client_location = message[4]
        client_time = message[5]
        relay_name = message[6]
        logInfo('success', 'AT: Received location info for' + ' ' + client_name + ' ' + 'from' + ' ' + server_name, self.factory)
        
        update = True
        if self.factory.users.has_key(client_name):
            last_client_time = self.factory.users[client_name][1]
            if last_client_time >= client_time:
                update = False
        
        if update:
            logInfo('success', 'AT: User' + ' ' + client_name + ' ' +'info needs to be updated', self.factory)
            self.factory.users[client_name] = (client_location, client_time,client_time_diff, server_name)
            for peer in self.factory.peers.keys():
                if peer == server_name or peer == relay_name:
                    continue
                info = self.factory.peers[peer]
                logInfo('success', 'AT: Sending information to peer:' + ' ' + peer, self.factory)
                peer_host = info[0]
                peer_port = info[1]
                line = message[0] + ' ' + message[1] + ' ' + message[2] + ' ' + message[3] + ' ' + message[4] + ' ' + message[5] + ' ' + self.factory.server
                connecttcp('success', peer_port, peer, peer_host, line, self.factory)
                logInfo('success', 'AT: Connecting to peer:' + ' ' + peer + ' ' + peer_host + ' ' + str(peer_port), self.factory)
        else:
            logInfo('success', 'AT: User' + ' ' + client_name + ' ' + "info doesn't need to be updated", self.factory)

    def handle_ERROR(self, line):
        self.message('?' + ' ' + line)
        self.transport.loseConnection()

    def message(self, message):
        self.transport.write(message + '\n')

    def tweets(self, location, radius, num):
        return str('{"results":[{"location":"Ever","profile_image_url":"http://a3.twimg.com/profile_images/524342107/avatar_normal.jpg","created_at":"Fri, 16 Nov 2012 07:38:34 +0000","from_user":"C_86","to_user_id":null,"text":"RT @ionmobile: @SteelCityHacker everywhere but nigeria // LMAO!","id":5704386230,"from_user_id":34011528,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://socialscope.net&quot; rel=&quot;nofollow&quot;&gt;SocialScope&lt;/a&gt;"},{"location":"Ever","profile_image_url":"http://a3.twimg.com/profile_images/524342107/avatar_normal.jpg","created_at":"Fri, 16 Nov 2012 07:37:16 +0000","from_user":"C_86","to_user_id":null,"text":"RT @ionmobile: 25 minutes left! RT Who will win????? Follow @ionmobile","id":5704370354,"from_user_id":34011528,"geo":null,"iso_language_code":"en","source":"&lt;a href=&quot;http://socialscope.net&quot; rel=&quot;nofollow&quot;&gt;SocialScope&lt;/a&gt;"}],"max_id":5704386230,"since_id":5501341295,"refresh_url":"?since_id=5704386230&q=","next_page":"?page=2&max_id=5704386230&rpp=2&geocode=27.5916%2C86.564%2C100.0km&q=","results_per_page":2,"page":1,"completed_in":0.090181,"warning":"adjusted since_id to 5501341295 (2012-11-07 07:00:00 UTC), requested since_id was older than allowed -- since_id removed for pagination.","query":""}' + '\n')

def flood_to_peer(p, line):
    p.sendLine(line)

def logInfo(p, message, factory):
    message = 'INFO:' + ' ' + message
    print(message)
    try:
        factory.logFile.write(message+'\n')
    except ValueError as e:
        print('Could not write into LogFile.')

def connecttcp(p, peer_port, peer, peer_host,peerMessage, factory):
    TCP4ClientEndpoint(reactor, peer_host, peer_port).connect(factory).addCallback(flood_to_peer, peerMessage).addCallback(logInfo, 'Connection established from' + ' '+ factory.server + ' ' + 'to' + ' ' + peer,factory).addErrback(connecttcp, peer_port, peer, peer_host, peerMessage, factory)

class ChatFactory(Factory):

    def __init__(self, server, host, port):
        self.server = server
        
        self.users = {}
        self.peers = {}
        if server == 'Farmar':
            self.peers['Meeks'] = ('localhost', 12630)
            self.peers['Young'] = ('localhost', 12631)
        elif server == 'Gasol':
            self.peers['Meeks'] = ('localhost', 12630)
            self.peers['Young'] = ('localhost', 12631)
        elif server == 'Meeks':
            self.peers['Hill'] = ('localhost', 12632)
            self.peers['Gasol'] = ('localhost', 12633)
            self.peers['Farmar'] = ('localhost', 12634)
        elif server == 'Hill':
            self.peers['Meeks'] = ('localhost', 12630)
        elif server == 'Young':
            self.peers['Gasol'] = ('localhost', 12633)
            self.peers['Farmar'] = ('localhost', 12634)
        self.host = host
        self.port = port
        self.directory = './{0}'.format(self.server)
        if not os.path.exists(self.directory):
            os.makedirs(self.directory)
        self.logFile = open('./{0}/{0}_{1}.log'.format(self.server, datetime.datetime.utcnow().isoformat().replace(':', '_').replace('T', '_')), 'a')
        self.logERR = open('./{0}/{0}_{1}_error.log'.format(self.server, datetime.datetime.utcnow().isoformat().replace(':', '_').replace('T', '_')), 'a')
        logInfo('success', server + ':' + ' ' + 'Server established', self)

    def stopFactory(self):
        logInfo('success', self.server + ':' + ' ' + 'Server closed', self)
        self.logFile.close()


    def logERR(self, message):
        message = 'ERROR:' + ' ' + message
        print(message)
        try:
            self.logFile.write(message+'\n')
        except ValueError as e:
            print('Could not write into LogFile.')


    def buildProtocol(self, addr):
        return Chat(self)


if __name__ == '__main__':
	factory = ChatFactory(sys.argv[1], sys.argv[2], int(sys.argv[3]))
	reactor.listenTCP(int(sys.argv[3]), factory)
	reactor.run()


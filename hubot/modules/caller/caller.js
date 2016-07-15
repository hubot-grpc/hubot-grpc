const grpc = require('grpc');
const Hashmap = require('hashmap');

module.exports = class caller {
  constructor(protoPath, serviceHost) {
    this.proto = grpc.load(protoPath);
    this.serviceHost = serviceHost;
    this.ongoingStreams = new Hashmap();
  }

  call(parsedCall, printResponse, printError) {
    return initCall(this.proto, this.serviceHost, this.ongoingStreams, parsedCall, printResponse, printError);
  }

  stream(id, parsedParams) {
    if (this.ongoingStreams.has(id)) {
      this.ongoingStreams.get(id).write(parsedParams);
    } else {
      throw new Error('There is no such ongoing stream');
    }
  }

  get streams() {
    return this.ongoingStreams.keys();
  }

  endStream(id) {
    if (this.ongoingStreams.has(id)) {
      this.ongoingStreams.get(id).end();
      this.ongoingStreams.remove(id);
    }
  }
};

// Private Helpers
function initCall(proto, serviceHost, ongoingStreams, parsedCall, printResponse, printError) {
  let procedureName = parsedCall.method[parsedCall.method.length - 1];
  // Procedures are always accessed starting with lowercase letters (no idea why ... really stupid)
  // -> convert the first character to lowercase
  procedureName = procedureName.charAt(0).toLowerCase() + procedureName.slice(1);

  let serviceName = parsedCall.method[parsedCall.method.length - 2];
  let packages = parsedCall.method.slice(0, -2);

  // unpack the service object
  let innerPackage = proto;
  packages.forEach(package => {
    innerPackage = innerPackage[package];
  });
  let serviceClient = new innerPackage[serviceName](serviceHost, grpc.credentials.createInsecure());

  // proceed with call
  return makeCall(serviceClient, procedureName, parsedCall.parameters, ongoingStreams, printResponse, printError);
}

function makeCall(serviceClient, procedure, request, ongoingStreams, printResponse, printError) {
  if (serviceClient[procedure].requestStream) {
    if (serviceClient[procedure].responseStream) {
      // bidirectional stream
      return callBidirectionalStream(serviceClient, procedure, request, ongoingStreams,  printResponse, printError);
    } else {
      // client streams to server
      return callStreamingRequest(serviceClient, procedure, request, ongoingStreams,  printResponse, printError);
    }
  } else {
    if (serviceClient[procedure].responseStream) {
      // server streams to client
      return callStreamingResponse(serviceClient, procedure, request, printResponse, printError);
    } else {
      // unary call
      return callUnary(serviceClient, procedure, request, printResponse, printError);
    }
  }
}

function callUnary(serviceClient, procedure, request, printResponse, printError) {
  serviceClient[procedure](request, (err, res) => {
    if (err) {
      printError(err);
    } else {
      printResponse(res);
    }
  });
  return { clientStream: false };
}

function callStreamingResponse(serviceClient, procedure, request, printResponse, printError) {
  let call = serviceClient[procedure](request);
  call.on('data', printResponse);

  return { clientStream: false };
}

function callStreamingRequest(serviceClient, procedure, request, ongoingStreams,  printResponse, printError) {
  let id = getUnusedId(ongoingStreams);
  let call = serviceClient[procedure]((err, res) => {
    if (err) { printError(err); } else { printResponse(res); }
    // if the call ended with the callback: remove the call from the ongoingStreams if it is still there
    ongoingStreams.remove(id);
  });
  ongoingStreams.set(id, call);

  call.write(request);

  return { clientStream: true, id: id };
}

function callBidirectionalStream(serviceClient, procedure, request, ongoingStreams,  printResponse, printError) {

  let call = serviceClient[procedure]();
  let id = getUnusedId(ongoingStreams);
  ongoingStreams.set(id, call);

  call.write(request);
  call.on('data', data => {
    printResponse(data);
  });
  call.on('end', () => {
    ongoingStreams.remove(id);
  });

  return { clientStream: true, id: id };
}

// Returns the smallest number >= 1 for which no key is in the given hashmap
function getUnusedId(ongoingStreams) {
  let keys = ongoingStreams.keys();
  sortedKeys = keys.sort();
  var i;
  for (i = 0; i < sortedKeys.length; i++) {
    if (sortedKeys[i] != i + 1) {
      return i + 1;
    }
  }

  return i + 1;
}

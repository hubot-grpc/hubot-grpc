const ProtoBuf = require('protobufjs');

module.exports = class ProtoHelper {
  constructor(builder) {
    this.types = require('./types');
    if (typeof builder === 'string') {
      this.builder = ProtoBuf.protoFromFile(builder);
    } else {
      this.builder = builder;
    }
  }

  validateCall(call) {
    let method = this.builder.lookup(call.fqn);
    if (!method) {
      throw new Error(`Procedure "${call.fqn}" not found.`);
    }

    if (!(method instanceof ProtoBuf.Reflect.Service.Method)) {
      throw new Error(`"${call.fqn}" is no procedure.`);
    }

    return this.validateMessage(method.resolvedRequestType.fqn(), call.request);
  }

  validateMessage(messageFqn, value) {
    if (typeof value !== 'object') {
      throw new Error(`Message "${messageFqn}" needs to be specified as an object but is a ${typeof value}`);
    }

    if (value instanceof Array) {
      throw new Error(`Message "${messageFqn}" needs to be specified as an object but is an array`);
    }

    var message = this.builder.lookup(messageFqn);
    if (!message) {
      throw new Error(`No Definition found for the message: ${messageFqn}`);
    }

    var fields = message.getChildren(ProtoBuf.Reflect.Message.Field);

    let omissions = [];
    Object.keys(value).forEach(key => {
      let field = fields.find(f => f.name === key);
      if (!field) {
        throw new Error(`"${key}" is not a defined field of ${messageFqn}.`);
      }
    });
    fields.forEach(field => {
      // in proto3 every field is optional .. skip not existing ones but add them to omissions
      if (value[field.name]) {
        let providedField = value[field.name];
        // for repeated fields: one value can be passed as usual, multiple as array
        if (field.repeated && providedField instanceof Array) {
          // check for every element of the array
          providedField.forEach(fieldItem => {
            let recursiveOmissions = this.checkField(messageFqn, field, fieldItem);
            omissions = omissions.concat(recursiveOmissions);
          });
        } else {
          // just check the single provided value
          let recursiveOmissions = this.checkField(messageFqn, field, providedField);
          omissions = omissions.concat(recursiveOmissions);
        }
      } else {
        omissions.push(`${message.fqn()}#${field.name}`);
      }
    });
    return omissions;
  }

  checkField(messageFqn, field, providedField, recursiveCallForMap) {

    // Need this optional parameter to stop the recursion into the map case -> but is ugly
    recursiveCallForMap = recursiveCallForMap || false;

    let omissions = [];
    // Handle maps separately
    if (field.map && !recursiveCallForMap) {
      for (let key in providedField) {
        // First try to validate the key
        // Hack -> try to mock a field to the recursive call (works because its a scalar for sure)
        this.checkField(messageFqn, { type: field.keyType }, key);
        // validate the value type
        omissions = omissions.concat(this.checkField(messageFqn, field, providedField[key], true));
      }
    // No map here..
    } else {
      switch (field.type.name) {
        // recursively check nested messages
        case 'message':
          let fqn = field.resolvedType.fqn();
          // Should be an object
          if (typeof providedField !== 'object') {
            throw new Error(`Field "${field.name}" (type: ${fqn}) needs to be specified as an object but is a ${typeof providedField}`);
          }

          if (providedField instanceof Array) {
            throw new Error(`Field "${field.name}" (type: ${fqn}) needs to be specified as an object but is an array`);
          }

          omissions = this.validateMessage(fqn, providedField);
          break;

        // check enum usage
        case 'enum':
          let possibleValues = field.resolvedType.getChildren(ProtoBuf.Reflect.Enum.Value).map(value => value.name);

          if (!possibleValues.find(value => value === providedField)) {
            throw new Error(`Field "${field.name}" (enumtype: ${field.resolvedType.fqn()}) has possible values ["${possibleValues.join('", "')}"] but "${providedField}" provided`);
          }

          break;

        // only primitive types (or not supported ones) should come up
        default:
          // Check the primitive type definitions for requested type
          if (field.type.name in this.types) {
            // Check if the type matches
            if (!this.types[field.type.name](providedField)) {
              throw new Error(`Provided field "${field.name}" of "${messageFqn}" must be of type ${field.type.name} but found ${typeof providedField}.`);
            }
          } else {
            // This is something we didn't yet thought of.. Might be Maps or different things
            throw new Error(`Unknown field type for field ${field.name}: ${field.type.name} (not yet implemented)`);
          }
      }
    }

    return omissions;
  }

  getAllMethods() {
    let rawMethods = getRawMethods(this.builder);
    let methods = rawMethods.map(rawMethod => {
      let method = { name: '', parameters: [] };
      method.name = rawMethod.fqn();
      let requestParameters = rawMethod.resolvedRequestType.getChildren(ProtoBuf.Reflect.Message.Field);
      requestParameters.forEach(field => {
        let parameter = {};
        if (field.resolvedType) {
          // non-primitive type
          parameter.type = field.resolvedType.name;
        } else {
          // primitive type
          parameter.type = field.type.name;
        }

        parameter.repeated = field.repeated;
        parameter.name = field.name;
        method.parameters.push(parameter);
      });
      return method;
    });
    return methods;
  }
};

function getRawMethods(builder) {
  let services = getAllServices(builder);
  let serviceFqns = services.map(service => service.fqn());

  let methods = [];
  serviceFqns.forEach(fqn =>
    methods = methods.concat(getMethodsForService(fqn, builder))
  );

  return methods;
}

function getMethodsForService(serviceFqn, builder) {
  let methods = [];
  builder.lookup(serviceFqn).getChildren(ProtoBuf.Reflect.Service.Method).forEach(method => {
    methods = methods.concat(method);
  });
  return methods;
}

function getAllServices(builder, fqn) {
  fqn = fqn || '';
  let services = [];
  builder.lookup(fqn).getChildren(ProtoBuf.Reflect.Service).forEach(service => {
    services.push(service);
  });
  builder.lookup(fqn).getChildren(ProtoBuf.Reflect.Namespace).forEach(service => {
    services = services.concat(getAllServices(builder, service.fqn()));
  });

  return services;
}

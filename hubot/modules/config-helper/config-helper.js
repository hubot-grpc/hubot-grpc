const yaml = require('js-yaml');
const handlebars = require('handlebars');
const fs = require('fs');

module.exports = class ConfigHelper {

  constructor(path, methods) {
    // Try to load the config file
    let configyaml = '';
    try {
      configyaml = fs.readFileSync(path, 'utf8');
    } catch (err) {}

    // Try to parse the yaml config file (throws if not parsable)
    this.config = yaml.safeLoad(configyaml) || {};
    this.initConfig(this.config);

    this.applyConfigToMethods(methods);
    this.methods = methods;
  }

  // Initializes default values for the config
  initConfig(rawConfig) {
    if (!('allow_default_calls' in rawConfig)) {
      rawConfig.allow_default_calls = true;
    }

    if (!('procedure_options' in rawConfig)) {
      rawConfig.procedure_options = [];
    }
  }

  // Adds information from the config file to the methods
  applyConfigToMethods (methods) {
    methods = methods || [];
    methods.map(method => {
      let permission = this.config.allow_default_calls;

      let option = this.config.procedure_options.find(option => option.procedure === method.name);
      if (option) {
        if ('allow_default_call' in option) {
          permission = option.allow_default_call;
        }

        if ('alias' in option) {
          method.alias = option.alias;
        }

        if ('help' in option) {
          method.help = option.help;
        }

        if ('response_templates' in option) {
          method.response_templates = option.response_templates;
        }

        if ('allowed_users' in option) {
          method.allowed_users = option.allowed_users;
        }

        if ('defaults' in option) {
          method.defaults = option.defaults;
        } else {
          method.defaults = {};
        }
      }

      method.isDefaultCallAllowed = permission;
      return method;
    });
  }

  getAliases() {
    let aliases = [];
    this.methods.forEach(method => {
      if (method.alias) {
        let alias = {
          name: method.alias,
          methodFqn: method.name,
          // this currently allows parameters to be specified directly after the alias
          // (without whitespace) -> might leed to clashes between aliases having a common prefix
          regexp: new RegExp(method.alias + '([\\s\\S]*)', 'i'),
          methodSplit: method.name.replace('.', '').split('.'),
        };
        aliases.push(alias);
      }
    });
    return aliases;
  }

  findMethodByFqn(methodFqn) {
    return this.methods.find(method => method.name === methodFqn);
  }

  isUserAllowed(methodFqn, username) {
    let method = this.findMethodByFqn(methodFqn);
    if (method) {
      if (method.allowed_users) {
        return method.allowed_users.includes(username);
      }
      // if not defined in config -> default is allowed
      return true;
    }
    // should not happen on validated methods
    return false;
  }

  getDefaultParameters(methodFqn) {
    let method = this.findMethodByFqn(methodFqn);

    if (method && method.defaults) {
      return method.defaults;
    }

    return {};
  }

  applyUserParametersToDefaults(methodFqn, userParameters) {
    // Create a deep copy of the object
    // (not sure if this is the best way but its also done by others)
    let parameters = JSON.parse(JSON.stringify(this.getDefaultParameters(methodFqn)));
    // Override default parameters with user parameters
    for (var key in userParameters) {
      parameters[key] = userParameters[key];
    }

    return parameters;
  }

  getResponseTemplates(methodFqn) {
    let method = this.findMethodByFqn(methodFqn);

    if (method && method.response_templates) {
      return method.response_templates.map(string => handlebars.compile(string));
    }

    return [context => yaml.safeDump(context.response).trim()];
  }

  getCommands() {
    let commands = [];

    this.methods.forEach(method => {

      // If there is an alias defined: Output command using alias
      if (method.alias) {
        // Mighty Template String for alias commands
        let aliasCommand = `${method.alias} ${method.parameters.map(param =>
          `<${param.name}:${param.type}${param.repeated ? '[]' : ''}>`).join(' ')}${method.help ? ` - ${method.help}` : ''}`.trim();
        commands.push(aliasCommand);
      }
      // If the default call is allowed: Output default command
      if (method.isDefaultCallAllowed) {
        // Mighty Template String for default commands
        let defaultCommand = `call ${method.name} ${method.parameters.map(param =>
          `<${param.name}:${param.type}${param.repeated ? '[]' : ''}>`).join(' ')}${method.help ? ` - ${method.help}` : ''}`.trim();
        commands.push(defaultCommand);
      }

    });

    return commands;
  }

  isDefaultCallAllowed(methodFqn) {
    let method = this.methods.find(method => method.name === methodFqn);

    return method && method.isDefaultCallAllowed;
  }
};

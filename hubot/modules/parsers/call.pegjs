/*
 * Simple procedure call Grammar
 * ==========================
 *
 * Accepts expressions namespace.cool_service.method parm1:"meh" param2:123 param3:true
 */
{
    const url = require('url');

    function flatten(a) {
        if (a instanceof Array) {
            var result = "";
            for (var i=0; i < a.length; i++) {
                result += flatten(a[i]);
            }
            return result;
        } else {
            return "" + a;
        }
    }
}
Command
  = _ method:MethodName _ params:Parameters {
  return {'method':method, 'fqn': '.' + method.join('.'), 'parameters':params}
}

Parameters
  = _ params:(param:Parameter _ {return param})* _
  {
  	var parameters = {}
    params.forEach(param => parameters[param.name] = param.value)
  	return parameters
  }


MethodName
 = "."? first:ObjectName tail:("." service:ObjectName {return service})* {
   return [first].concat(tail)
 }
ObjectName
  = (alpha alphanum*) { return text() }

Parameter
  = parameter:ObjectName _ ':' _ value:ParameterValue {
    return {'name': parameter, 'value': value}
  }

ParameterValue = String / Bytestring / Url / Boolean  / Float / Integer / List / Dict
Integer "integer"
  = [-+]?[0-9]+ { return parseInt(text(), 10); }
Float "float"
  = [-+]?[0-9]*'.'?[0-9]+ { return parseFloat(text())}

List "list"
  = "[" _ params:(param:ParameterValue _ "," _ {return param;})* param:ParameterValue _ "]" {
    params.push(param);
    return params
  }

Dict "dictionary"
  = "{" _ entries:(entry:Parameter _ "," _ { return entry;})* entry:Parameter _ "}" {
    var dict = {};
    entries.forEach(function (param) {
      dict[param["name"]] = param['value'];
    });
    dict[entry["name"]] = entry['value'];
    return dict;
  }
alpha = [a-zA-Z]
alphanum = [a-zA-Z0-9_]
hexdigit = [0-9a-fA-F]
Url =
        (
            'url"'
            s:(
                (
                    '\\'
                    e:escseq
                    {
                        return e;
                    }
                )
            /   [^\\"]
            )*
            '"'
        )
        {
            return url.parse(flatten(s));
        }
Bytestring =
        (
            'b"'
            s:(
                (
                    '\\'
                    e:escseq
                    {
                        return e;
                    }
                )
            /   [^\\"]
            )*
            '"'
        )
        {
            var buffer = new Buffer(flatten(s));
            return buffer
        }
String "string" =
        (
            '"'
            s:(
                (
                    '\\'
                    e:escseq
                    {
                        return e;
                    }
                )
            /   [^\\"]
            )*
            '"'
        )
        {
            return flatten(s);
        }
    /   (
            "'"
            s:(
                (
                    '\\'
                    e:escseq
                    {
                        return e;
                    }
                )
            /   [^\\']
            )*
            "'"
        )
        {
            return flatten(s);
        }
escseq =
        (
            k:[bfnrt]
            {
                switch (k) {
                    case "b": return "\b";
                    case "f": return "\f";
                    case "n": return "\n";
                    case "r": return "\r";
                    default:  return "\t";
                }
            }
        )
    /   (
            'u' hd:(hexdigit hexdigit hexdigit hexdigit)
            {
                return String.fromCharCode(parseInt(flatten(hd), 16));
            }
        )
    /   (
            // Any other escaped char is passed as is
            j:.
            {
                return j;
            }
        )
chars = [^ \t\n\r "]*
Boolean "boolean" = 'true'i {return true;} / 'false'i {return false;}
_ "whitespace"
  = [ \t\n\r]*

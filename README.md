## Etcd Package

This is a [Kurtosis Starlark Package](https://docs.kurtosis.com/quickstart) that allows you to spin up an etcd instance.

### Run

This assumes you have the [Kurtosis CLI](https://docs.kurtosis.com/cli) installed

Simply run

```bash
kurtosis run github.com/kurtosis-tech/etcd-package
```

#### Configuration

<details>
    <summary>Click to see configuration</summary>

You can configure this package using a JSON structure as an argument to the `kurtosis run` function. The full structure that this package accepts is as follows, with default values shown (note that the `//` lines are not valid JSON and should be removed!):

```javascript
{
    // The name to give the new etcd service
    "etcd_name": "etcd",

    // The image to run
    "etcd_image": "softlang/etcd-alpine:v3.4.14",

    // The client port number to listen on and advertise
    "etcd_client_port": 2379,

    // Additional environment variables that will be set on the container
    "etcd_env_vars": {}
}
```

These arguments can either be provided manually:

```bash
kurtosis run github.com/kurtosis-tech/etcd-package '{"etcd_image":"softlang/etcd-alpine:v3.4.14"}'
```

or by loading via a file, for instance using the [args.json](args.json) file in this repo:

```bash
kurtosis run github.com/kurtosis-tech/etcd-package --enclave etcd "$(cat args.json)"
```

</details>

### Using this in your own package

Kurtosis Packages can be used within other Kurtosis Packages, through what we call composition internally. Assuming you want to spin up etcd and your own service
together you just need to do the following

```py
main_etcd_module = import_module("github.com/kurtosis-tech/etcd-package/main.star")

# main.star of your etcd + Service package
def run(plan, args):
    plan.print("Spinning up the etcd Package")
    # this will spin up etcd and return the output of the etcd package
    etcd_run_output = main_redis_module.run(plan, args)
```

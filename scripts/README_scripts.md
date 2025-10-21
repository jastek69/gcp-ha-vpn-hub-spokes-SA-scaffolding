



Best Practice Staged Apply

Because of these dependencies, your apply-test.sh should be staged like this:

Step 1: IAM + Custom Roles

Step 2: VPCs

Step 3: Routers

Step 4: Gateways

Step 5: Tunnels



run either staged apply or staged destroy safely by passing a flag (apply or destroy).
For use with Ci/CD Pipelines


lifecycle.sh
```
chmod +x lifecycle.sh

# To build staged
./lifecycle.sh apply

# To teardown staged (reverse order)
./lifecycle.sh destroy
```





lifecycle-safe.sh

Pauses after each stage and requires you to confirm before continuing. That way you can carefully watch the GCP console/logs and avoid racing conditions (like routers not being “ready” yet).

```
chmod +x lifecycle-safe.sh

# To build with pauses:
./lifecycle-safe.sh apply

# To tear down with pauses:
./lifecycle-safe.sh destroy
```


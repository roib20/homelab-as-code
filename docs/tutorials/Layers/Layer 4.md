# Layer 4: Taskfile (Talos Cluster)

1. Create `.env` file: `cp "env.example" ".env"`
2. Fill out secret values.
3. Bootstrap cluster using the following command:

    ```shell
    docker compose run --user "$(id -u):$(id -g)" --rm runner bash -c "task cluster:up"
    ```

4. Once cluster is bootstrapped, if everything was configured correctly, Argo CD will be deployed and then the rest of the cluster resources would automatically get deployed using GitOps.

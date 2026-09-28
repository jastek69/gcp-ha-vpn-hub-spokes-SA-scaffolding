To grants and be sure the Service Accounts 

Login with Default credentials:
`gcloud auth application-default login`


Verify project permissions:
`gcloud projects get-iam-policy changing3-15-25 \
  --flatten="bindings[]" \
  --format="table(bindings.role, bindings.members)" \
  --filter="bindings.members:user:you@example.com"`


Check projects for roles:

`gcloud iam service-accounts get-iam-policy terraform@taaops.iam.gserviceaccount.com \
  --project=taaops --format='table(bindings.role, bindings.members)'`
  
  
`gcloud iam service-accounts get-iam-policy terraform@genosha-ops.iam.gserviceaccount.com \
  --project=genosha-ops --format='table(bindings.role, bindings.members)'`

`gcloud iam service-accounts get-iam-policy jasops-terraform@jasops.iam.gserviceaccount.com \
  --project=jasops --format='table(bindings.role, bindings.members)'`

`gcloud iam service-accounts get-iam-policy terraform-service@class-6-5-tiqs.iam.gserviceaccount.com \
  --project=class-6-5-tiqs --format='table(bindings.role, bindings.members)'`


`gcloud iam service-accounts get-iam-policy terraform-service-delta@changing3-15-25.iam.gserviceaccount.com \
  --project=changing3-15-25 --format='table(bindings.role, bindings.members)'`


Complete listing:
 `gcloud projects get-iam-policy jasops \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:jastek.sweeney@gmail.com" \
  --format="table(bindings.role, bindings.members)"`
create or replace function get_customer(int) returns jsonb as $$
  with data as (
    select t.stripe_customer_id,
           t.stripe_subscription_id,
           t.ownerid::text,
           t.service_id,
           t.plan_user_count,
           t.plan_provider,
           t.plan_auto_activate,
           t.plan_activated_users,
           t.plan, t.email,
           t.free, t.did_trial,
           t.invoice_details,
           get_users(t.admins) as admins,
           (select count(*)
            from repos
            where ownerid=t.ownerid
              and private
              and activated) as repos_activated
    from owners t
    where t.ownerid = $1
    limit 1
  ) select to_jsonb(data) from data limit 1;
$$ language sql stable strict;

# Run this with `ruby test.rb`

require 'tempfile'
require 'test/unit'

class ILoveOOP < Test::Unit::TestCase
  def quine?(file)
    sha1 = `sha1sum #{file}`.split(/\s/)[0]
    sha2 = `#{file} 2>/dev/null | sha1sum`.split(/\s/)[0]
    sha1 == sha2
  end

  def test_quineness
    assert(quine?("./quinedb"), "isn't even a quine")
  end

  def setup
    `rm -rf tmp/test`
    `mkdir -p tmp/test`
    `cp quinedb tmp/test/quinedb`
  end

  def teardown
    `rm -rf tmp`
  end

  def pr_str s
    s
  end

  def cmd *args
    args = "'#{args.map{|x|pr_str x}.join("' '")}'"
    `tmp/test/quinedb #{args} > tmp/test/out 2> tmp/test/err`
    `mv tmp/test/out tmp/test/quinedb`
    `chmod +x tmp/test/quinedb`
    res = `cat tmp/test/err`
    `rm tmp/test/err`
    res.strip
  end

  def test_crud
    [%w(k v k v), %w(ä ß ä ß), %w(* \\ \\* \\\\), ['k', '', 'k', "$''"]].each do |k, v, qk, qv|
      setup

      assert(cmd("keys") == "")
      assert(quine?("tmp/test/quinedb"))
      assert(cmd("set", k, v) == "OK")
      assert(quine?("tmp/test/quinedb"))
      assert(cmd("keys") == qk)
      assert(quine?("tmp/test/quinedb"))
      assert(cmd("set", "#{k}2", "#{v}2") == "OK")
      assert(quine?("tmp/test/quinedb"))
      assert(cmd("keys").split(/\n/).sort == %W(#{qk} #{qk}2))
      assert(cmd("get", k) == qv)
      assert(cmd("get", "#{k}2") == "#{qv.gsub("$''","")}2")
      assert(cmd("delete", "#{k}2") == "OK")
      assert(cmd("get", "#{qk}2") == "")
      assert(cmd("get", k) == qv)
      assert(quine?("tmp/test/quinedb"))
    end
  end
end
